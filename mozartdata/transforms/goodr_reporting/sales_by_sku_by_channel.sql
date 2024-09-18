SELECT 
  date_trunc('month',sold_date) as month, channel, p.family as category, merchandise_class, oi.sku,  plain_name, 
    SUM(quantity_sold) as units, SUM(oi.revenue) as revenue
FROM
  (SELECT * FROM fact.order_item where sku is not null) as oi 
  LEFT JOIN dim.product p on p.sku = oi.sku
  LEFT JOIN (SELECT DISTINCT order_id_edw, channel,sold_date FROM fact.orders) o on o.order_id_edw = oi.order_id_edw
    where year(sold_date) = 2024 --and plain_name = "A Gingers Soul"
group by 1,2,3,4,5,6
  order by month,plain_name, revenue desc
-------------------------------------------------------------------------------------------------------------------------