SELECT
  o.order_id_edw,
  o.sold_date,
  o.booked_date,
  o.order_id_ns,
  oi.order_item_id,
  oi.product_id_edw,
  oi.item_id_ns,
  oi.sku,
  oi.plain_name,
  oi.quantity_booked,
  oi.quantity_sold,
  oi.quantity_fulfilled,
  oi.quantity_refunded,
  oi.amount_booked,
  oi.amount_sold,
  oi.amount_refunded,
  oi.amount_fulfilled,
  p.family,
  p.stage,
  p.collection,
  p.merchandise_class,
  p.merchandise_department,
  p.merchandise_division,
  o.customer_id_edw,
  c.customer_name,
  c.primary_id_flag
FROM
  fact.order_item oi
  LEFT JOIN fact.orders o ON o.order_id_edw = oi.order_id_edw
  LEFT JOIN dim.product p ON p.product_id_edw = oi.product_id_edw
  LEFT JOIN fact.customer_ns_map c on o.customer_id_edw = c.customer_id_edw
WHERE
  o.channel = 'Global'
  and c.primary_id_flag = 'true'