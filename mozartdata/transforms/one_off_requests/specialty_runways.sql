SELECT 
  oi.*,
  o.channel,
  o.sold_date,
  p.merchandise_class,
  p.merchandise_department,
  p.merchandise_division,
  o.customer_id_edw,
  cnm.customer_id_ns,
  cs.customer_id_shopify,
  cs.full_name,
  ca.company
  
FROM fact.order_item oi
JOIN fact.orders o on o.order_id_edw = oi.order_id_edw
JOIN dim.product p on p.sku = oi.sku
JOIN fact.customer_ns_map cnm on cnm.customer_id_edw = o.customer_id_edw
JOIN fact.customer_shopify_map cs on cs.customer_id_edw = o.customer_id_edw
JOIN specialty_shopify.customer_address ca on cs.customer_id_shopify = ca.customer_id and ca.is_default = 'true'
WHERE 
  o.channel = 'Specialty'
  and o.sold_date > '2022-06-01'
  and p.merchandise_class = 'RUNWAYS'