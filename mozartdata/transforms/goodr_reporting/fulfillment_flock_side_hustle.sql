WITH
  stord_info AS (
    SELECT
      SPLIT_PART(fulfillment_id_edw, '_', 2) AS tracking,
      order_id_edw,
      shipment_id,
      warehouse_location,
      date(shipdate) shipdate,
      voided,
      sku,
      product_name,
      quantity
    FROM
      fact.fulfillment_item_detail
    WHERE
      source = 'Stord'
  ),
  booked_info AS (
    SELECT
      detail.order_id_ns,
      detail.transaction_id_ns,
      detail.transaction_created_date_pst,
      detail.full_status,
      prod.sku,
      detail.plain_name,
      detail.total_quantity,
      detail.quantity_backordered,
      detail.location,
      loc.name
    FROM
      fact.order_item_detail detail
      LEFT OUTER JOIN dim.product prod ON prod.item_id_ns = detail.item_id_ns
      LEFT OUTER JOIN dim.location loc ON loc.location_id_ns = detail.location
    WHERE
      record_type = 'salesorder'
      AND full_status NOT IN (
        'Sales Order : Billed',
        'Sales Order : Closed',
        'Sales Order : Cancelled'
      )
      AND plain_name NOT IN ('Shipping', 'Tax', 'Discount')
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