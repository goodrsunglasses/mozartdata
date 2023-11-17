SELECT 
  oi.*,
  c.customer_id_ns,
  o.customer_id_edw,
  cm.customer_id_ns,
  o.order_date_pst
FROM fact.order_item oi
  join fact.orders o on oi.order_id_edw = o.order_id_edw
  join fact.customer_ns_map c on o.customer_id_edw = c.customer_id_edw
  join fact.customer_ns_map cm on cm.customer_id_edw = o.customer_id_edw
WHERE channel = 'Specialty'
order by o.order_date_pst desc