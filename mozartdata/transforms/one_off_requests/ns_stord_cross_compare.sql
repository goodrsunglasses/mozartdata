WITH
  stord_info AS (
    SELECT distinct 
      SPLIT_PART(fulfillment_id_edw, '_', 2) AS tracking,
      order_id_edw,
      shipment_id,
      warehouse_location,
      date(shipdate) shipdate
    FROM
      fact.fulfillment_item_detail
    WHERE
      source = 'Stord'
  ),
  ns_info AS (
    SELECT
      *
    FROM
      fact.order_line
    WHERE
      record_type = 'salesorder'
      AND transaction_status_ns NOT IN (
        'Sales Order : Billed',
        'Sales Order : Closed',
        'Sales Order : Cancelled'
      )
      AND channel IN ('Specialty', 'Specialty CAN')
  ),
  backordered AS (
    SELECT DISTINCT
      order_id_edw,
      max(
        CASE
          WHEN quantity_backordered > 0 THEN TRUE
          ELSE FALSE
        END
      ) over (
        PARTITION BY
          order_id_edw
      ) AS backorder_flag
    FROM
      fact.order_item_detail
    WHERE
      record_type = 'salesorder'
  )
SELECT
  stord_info.order_id_edw,
  ns_info.transaction_id_ns,
  ns_info.transaction_number_ns,
  tracking,
  shipment_id,
  warehouse_location,
  shipdate
FROM
  stord_info
  LEFT OUTER JOIN ns_info ON ns_info.order_id_edw = stord_info.order_id_edw
  left outer join backordered on backordered.order_id_edw = stord_info.order_id_edw
WHERE
  ns_info.order_id_edw IS NOT NULL and backorder_flag = false