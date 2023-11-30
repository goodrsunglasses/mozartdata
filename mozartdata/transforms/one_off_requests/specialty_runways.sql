SELECT 
  oi.*,
  o.channel,
  o.sold_date,
  p.merchandise_class,
  p.merchandise_department,
  p.merchandise_division
  
FROM fact.order_item oi
JOIN fact.orders o on o.order_id_edw = oi.order_id_edw
JOIN dim.product p on p.sku = oi.sku
WHERE 
  o.channel = 'Specialty'
  and o.sold_date > '2022-06-01'
  and p.merchandise_class = 'RUNWAYS'