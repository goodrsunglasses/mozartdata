SELECT
  detail.order_id_ns,
  detail.transaction_id_ns,
  detail.item_id_ns,
  detail.transaction_created_date_pst,
  detail.record_type,
  detail.full_status,
  detail.item_type,
  detail.plain_name,
  detail.quantity_backordered,
  detail.location,
  loc.name,
  orders.quantity_fulfilled_stord
FROM
  fact.order_item_detail detail
  left outer join dim.location loc on loc.location_id_ns = detail.location
  left outer join fact.orders orders on orders.order_id_edw = detail.order_id_edw
WHERE
  record_type = 'salesorder'  and quantity_backordered >0 and quantity_fulfilled_stord is not null