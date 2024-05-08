WITH
  shipment_count AS (
    SELECT DISTINCT
      order_id_edw,
      COUNT(trackingnumber)
    FROM
      (
        SELECT
          ordernumber AS order_id_edw,
          trackingnumber
        FROM
          shipstation_portable.shipstation_shipments_8589936627 shipstation
        UNION
        SELECT
          order_number AS order_id_edw,
          tracking_number AS trackingnumber
        FROM
          stord.stord_shipment_confirmations_8589936822
      )
    GROUP BY
      order_id_edw
  ),
  edw_fulfillments AS (
    SELECT DISTINCT
      fulfillment_id_edw,
      order_id_edw
    FROM
      (
        SELECT
          ordernumber AS order_id_edw,
          trackingnumber,
          CONCAT(order_id_edw, '_', trackingnumber) AS fulfillment_id_edw
        FROM
          shipstation_portable.shipstation_shipments_8589936627 shipstation
        UNION
        SELECT
          order_number AS order_id_edw,
          tracking_number AS trackingnumber,
          CONCAT(order_id_edw, '_', trackingnumber) AS fulfillment_id_edw
        FROM
          stord.stord_shipment_confirmations_8589936822
      )
  ),
  shipstation AS (
    SELECT
      ordernumber AS order_id_edw,
      trackingnumber,
      CONCAT(order_id_edw, '_', trackingnumber) AS fulfillment_id_edw,
      shipmentid AS shipstation_id
    FROM
      shipstation_portable.shipstation_shipments_8589936627 shipstation
  ),
  stord AS (
    SELECT
      order_number AS order_id_edw,
      tracking_number AS trackingnumber,
      CONCAT(order_id_edw, '_', trackingnumber) AS fulfillment_id_edw,
      shipment_confirmation_id AS stord_id
    FROM
      stord.stord_shipment_confirmations_8589936822
  ),
  netsuite_step_one AS ( --the idea here is to weed out the 90% of NS orders with only one fulfillment, that aren't parent transaction split, that we can just 1:1 join based on order_id_edw
    SELECT
      *
    FROM
      (
        SELECT DISTINCT
          order_id_edw,
          transaction_id_ns,
          count(order_id_edw) over ( --window function because I want all the other fields out of dim.parent_transactions but only am looking for where one order_id_edw doesn't have multiple IF's
            PARTITION BY
              order_id_edw
          ) counter
        FROM
          dim.parent_transactions
        WHERE
          record_type = 'itemfulfillment'
          AND order_id_edw NOT like('%#%')
      )
    WHERE
      counter = 1
  ),
  netsuite_step_two AS ( --the idea here is to filter for all the Itemfulfillments that we can use the tracking numbers of to link to their source systems,
      -- an example being CS-LST-SD-G2501679 whose two IF's have different tracking numbers, basically tracking number based joining
    SELECT
      *
    FROM
      (
        SELECT DISTINCT
          parent_transactions.order_id_ns,
          parent_transactions.transaction_id_ns,
          number.trackingnumber,
          CONCAT(
            parent_transactions.order_id_ns,
            '_',
            number.trackingnumber
          ) fulfillment_id_edw, --basically creating a fulfillment_id_edw from the IF because all the ones filtered for only have one
          count(parent_transactions.order_id_edw) over (
            PARTITION BY
              parent_transactions.order_id_edw
          ) counter
        FROM
          dim.parent_transactions
          LEFT OUTER JOIN netsuite_step_one ON netsuite_step_one.transaction_id_ns = parent_transactions.transaction_id_ns
          LEFT OUTER JOIN netsuite.trackingnumbermap map ON map.transaction = parent_transactions.transaction_id_ns
          LEFT OUTER JOIN netsuite.trackingnumber number ON number.id = map.trackingnumber
        WHERE
          record_type = 'itemfulfillment'
          AND netsuite_step_one.transaction_id_ns IS NULL
        and parent_transactions.order_id_edw like('%#%')
      )
    WHERE
      counter = 1
    and trackingnumber is not null
  ),
  netsuite_step_three AS ( --step to get the split shipments based on fulfillment id as well, that also dont have a #
    SELECT
      *
    FROM
      (
        SELECT DISTINCT
          parent_transactions.order_id_ns,
          parent_transactions.transaction_id_ns,
          number.trackingnumber,
          CONCAT(
            parent_transactions.order_id_ns,
            '_',
            number.trackingnumber
          ) fulfillment_id_edw, --basically creating a fulfillment_id_edw from the IF because all the ones filtered for only have one
          count(parent_transactions.order_id_edw) over (
            PARTITION BY
              parent_transactions.order_id_edw
          ) counter
        FROM
          dim.parent_transactions
          LEFT OUTER JOIN netsuite_step_one ON netsuite_step_one.transaction_id_ns = parent_transactions.transaction_id_ns
          LEFT OUTER JOIN netsuite.trackingnumbermap map ON map.transaction = parent_transactions.transaction_id_ns
          LEFT OUTER JOIN netsuite.trackingnumber number ON number.id = map.trackingnumber
        WHERE
          record_type = 'itemfulfillment'
          AND netsuite_step_one.transaction_id_ns IS NULL
        and parent_transactions.order_id_edw NOT like('%#%')
      )
    WHERE
      counter != 1
    and trackingnumber is not null
  )

SELECT
  edw_fulfillments.fulfillment_id_edw,
  edw_fulfillments.order_id_edw,
  COALESCE(TO_CHAR(shipstation_id), stord_id) source_system_id,
  array_agg(coalesce(
    netsuite_step_one.transaction_id_ns,
    netsuite_step_two.transaction_id_ns,
    netsuite_step_three.transaction_id_ns
  ) ) itemfulfillment_ids,
  MAX(
    CASE
      WHEN shipstation_id IS NULL THEN 'Stord'
      ELSE 'Shipstation'
    END
  ) source_system
FROM
  edw_fulfillments
  LEFT OUTER JOIN shipstation ON shipstation.fulfillment_id_edw = edw_fulfillments.fulfillment_id_edw
  LEFT OUTER JOIN stord ON stord.fulfillment_id_edw = edw_fulfillments.fulfillment_id_edw
  LEFT OUTER JOIN netsuite_step_one ON netsuite_step_one.order_id_edw = edw_fulfillments.order_id_edw
  LEFT OUTER JOIN netsuite_step_two ON netsuite_step_two.fulfillment_id_edw = edw_fulfillments.fulfillment_id_edw
LEFT OUTER JOIN netsuite_step_three ON netsuite_step_three.fulfillment_id_edw = edw_fulfillments.fulfillment_id_edw
GROUP BY
  edw_fulfillments.fulfillment_id_edw,
  edw_fulfillments.order_id_edw,
  source_system_id
order by fulfillment_id_edw