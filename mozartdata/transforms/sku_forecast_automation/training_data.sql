SELECT 
  month, display_name, sku, merchandise_class, family,collection,qty,lag12 ,
  ROW_NUMBER() OVER (PARTITION by sku ORDER BY month desc) as num_sample --to get most recent data to model off of 
  from
(SELECT *,
  abs(qty-lag12) as diff,
 LEAST( AVG(abs(qty-lag12)) OVER (PARTITION by sku)+ 2*STDdev(abs(qty-lag12)) OVER (PARTITION BY sku) , --to flag outliers
  approx_percentile(abs(qty-lag12),0.5) OVER (PARTITION by sku) 
  + 2*(approx_percentile(abs(qty-lag12),0.75) OVER (PARTITION by sku) -  approx_percentile(abs(qty-lag12),0.25) OVER (PARTITION by sku))) outlier_flag
  from

  
(SELECT
  *,
  count(*) OVER (PARTITION BY sku) as total_data, -- to get skus with the most data in months
  LAG(qty,12) OVER (PARTITION BY sku order by month ) lag12 -- lag by one year
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

  
where total_data >= 15 -- filter for sufficient data
  and lag12 is not null -- get rid of months that done have a lag 12 
  and month < date_trunc('month',CURRENT_DATE())
order by sku, month)

  
WHERE diff < outlier_flag -- get rid out outliers