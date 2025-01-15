with data as (SELECT  MONTH(sold_date) as month,
  channel, coalesce(old_map.display_name,new_map.display_name,p.display_name) display_name, 
  p.sku,
  p.family,
  p.merchandise_class,
p.stage,
  SUM(oi.quantity_sold) as qty,count(distinct o.customer_id_edw) as customers , sum(oi.revenue) as revenue
  FROM fact.order_item oi
  INNER JOIN dim.product p on p.sku = oi.sku
  LEFT JOIN fact.orders o  on o.order_id_edw = oi.order_id_edw
  LEFT JOIN dim.old_to_new_sku_map  old_map on old_map.old_sku = oi.sku -- to get display_name for old sku 
  LEFT JOIN dim.old_to_new_sku_map  new_map on new_map.new_sku = oi.sku -- to get the display_name for new sku 
where year(sold_date) = 2025 and channel in ('Goodr.com','goodr.ca','Cabana','Amazon','Amazon Canada','TikTok Shop','Prescription','Specialty'
  ,'Specialty CAN','Key Accounts','Key Account CAN','Global')

group by all)

SELECT month, channel,display_name,sku,family,merchandise_class, stage, 'UNITS' as metric, qty
  FROM data 
UNION ALL 
SELECT month, channel,display_name,sku,family,merchandise_class, stage, 'REVENUE' as metric, revenue
  FROM data