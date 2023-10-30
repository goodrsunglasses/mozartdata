WITH
  sold AS (
    SELECT
      order_id_edw,
      transaction_id_ns,
      item_id_ns,
      transaction_timestamp_pst,
      plain_name,
      total_quantity,
      location,
      loc.fullname
    FROM
      fact.order_item_detail detail
      LEFT OUTER JOIN netsuite.location loc ON loc.id = detail.location
    WHERE
      record_type = 'salesorder'
      AND item_type = 'InvtPart'
      AND loc.fullname LIKE '%DO NOT USE%'
  ),
  fulfilled AS (
    SELECT
      order_id_edw,
      transaction_id_ns,
      item_id_ns,
      transaction_timestamp_pst,
      plain_name,
      total_quantity,
      location,
      loc.fullname
    FROM
      fact.order_item_detail detail
      LEFT OUTER JOIN netsuite.location loc ON loc.id = detail.location
    WHERE
      record_type = 'itemfulfillment'
      AND item_type = 'InvtPart'
  )
SELECT
  sold.order_id_edw order_number,
  sold.transaction_timestamp_pst timestamp_sold,
  sold.plain_name item_name,
  sold.total_quantity quantity_sold,
  sold.fullname location_sold,
  fulfilled.transaction_timestamp_pst timestamp_fulfilled,
  fulfilled.total_quantity quantity_fulfilled,
  fulfilled.fullname AS location_fulfilled
FROM
  sold
  LEFT OUTER JOIN fulfilled ON (
    fulfilled.order_id_edw = sold.order_id_edw
    AND fulfilled.item_id_ns = sold.item_id_ns
  )
WHERE
  location_fulfilled not like '%DO NOT USE%'