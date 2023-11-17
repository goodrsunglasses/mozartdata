SELECT 
  o.order_date_pst,
  oi.order_id_edw,
  c.customer_id_ns,
  p.sku,
  p.display_name,
  p.collection,
  oi.quantity_booked,
  oi.quantity_sold,
  oi.quantity_fulfilled,
  oi.quantity_refunded,
  oi.amount_booked,
  oi.amount_sold,
  oi.amount_fulfilled,
  oi.amount_refunded
--  o.customer_id_edw,
FROM fact.order_item oi
  join fact.orders o on oi.order_id_edw = o.order_id_edw
  join fact.customer_ns_map c on o.customer_id_edw = c.customer_id_edw
  join dim.product p on oi.product_id_edw = p.product_id_edw
WHERE channel = 'Specialty'
order by o.order_date_pst desc