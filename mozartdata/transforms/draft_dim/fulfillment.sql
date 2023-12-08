WITH
  edw_fulfillments AS (
    SELECT DISTINCT
      fulfillment_id_edw
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
  netsuite AS (
    SELECT
      order_id_edw,
      record_type,
      transaction_number_ns,
      transaction_created_timestamp_pst createddate,
      number.trackingnumber,
      map.transaction,
      CONCAT(order_id_edw, '_', number.trackingnumber) AS fulfillment_id_edw
    FROM
      netsuite.trackingnumber number
      LEFT OUTER JOIN netsuite.trackingnumbermap map ON number.id = map.trackingnumber
      LEFT OUTER JOIN fact.order_line line ON line.transaction_id_ns = map.transaction
  )
SELECT
  edw_fulfillments.fulfillment_id_edw,
  COALESCE(TO_CHAR(shipstation_id), stord_id) source_system_id,
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
GROUP BY
  edw_fulfillments.fulfillment_id_edw,
  source_system_id