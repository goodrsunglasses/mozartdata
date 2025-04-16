with date_map as 
  (SELECT  *
FROM (SELECT DISTINCT date_trunc('month',date) as month FROM dim.date where year(date) >= 2022 and date_trunc('month',date) < date_trunc('month',dateadd(year,1,CURRENT_DATE())))
LEFT JOIN (SELECT DISTINCT sku from sku_forecast_automation.training_data where family = 'INLINE') sku on 1=1
order by sku, month)
,
actual_data as 
(SELECT * FROM (SELECT
  *,
  count(*) OVER (PARTITION BY sku) as total_data, -- to get skus with the most data in months
  FROM
(SELECT  
  date_trunc('month',sold_date) as month,
  display_name, 
  p.sku,
  p.merchandise_class,
  p.family,
  p.collection,
  SUM(oi.quantity_sold) as qty
  FROM fact.order_item oi
  INNER JOIN dim.product p on p.sku = oi.sku
  INNER JOIN google_sheets.all_forecasting_skus_vince s on s.sku =oi.sku 
  LEFT JOIN fact.orders o  on o.order_id_edw = oi.order_id_edw
  where channel in ('Goodr.com','Specialty') 
group by all) data 
  
where display_name is not null and month is not null and family = 'INLINE' and merchandise_class != 'DISPLAYS'
ORDER by  sku,month)
where total_data >= 15)

  SELECT month,sku,lag12  FROM 
(SELECT 
d.month,d.sku, lag(qty,12) OVER (PARTITION by d.sku ORDER BY d.month) as lag12
FROM 
date_map d 
LEFT JOIN actual_data ad on ad.month = d.month and d.sku = ad.sku
order by d.sku,d.month)
where lag12 is not null and month >= date_trunc('month',current_date())

order by sku,month