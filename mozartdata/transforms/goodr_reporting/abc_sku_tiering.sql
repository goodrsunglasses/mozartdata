SELECT 

  *, CASE WHEN running_percent_total <=0.8 THEN 'A'
  WHEN running_percent_total <=0.95 THEN 'B'
  ELSE 'C' END AS TIER
  FROM 
(SELECT 
*, sum(percent_of_revenue) OVER (ORDER BY percent_of_revenue desc) as running_percent_total
  FROM 
(SELECT *,
  revenue/SUM(revenue) OVER () as percent_of_revenue 
  FROM 
(SELECT  
  display_name, 
  p.sku,
  p.merchandise_class,
  p.family,
  p.stage,
  p.collection,
  SUM(oi.quantity_sold) as qty,
  SUM(oi.revenue) as revenue
  FROM fact.order_item oi
  INNER JOIN dim.product p on p.sku = oi.sku
  INNER JOIN google_sheets.all_forecasting_skus_vince s on s.sku =oi.sku 
  LEFT JOIN fact.orders o  on o.order_id_edw = oi.order_id_edw
  where channel in ('Goodr.com','Specialty','goodr.ca','Specialty CAN', 'Amazon','Amazon Canada','Global','Key Accounts','Key Account CAN','TikTok Shop') 
  and family = 'INLINE' and stage = 'ACTIVE' and sold_date BETWEEN dateadd(year,-1,current_date()) and dateadd(day,-1,CURRENT_DATE())
group by all
order by SUM(oi.revenue) desc) a
order by revenue desc) b
order by revenue desc) c
order by revenue desc