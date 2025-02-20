/*
The purpose of this query is to look at the purchase behavior of people that bought runways 
so that we can evaluate if those same people are purhcasing Glam Gs, or if they have shifted their purchases to Pop G, or other models.
*/

WITH
  runway_skus AS (
    SELECT DISTINCT
      (product_id_edw)
    FROM
      dim.product
    WHERE
      merchandise_class = 'RUNWAYS'
  ),
  runway_customers AS (
    SELECT DISTINCT
      (customer_id_edw)
    FROM
      fact.order_item oi
      INNER JOIN runway_skus USING (product_id_edw)
  )
  --SELECT * FROM  runway_customers
SELECT
  oi.plain_name,
  p.merchandise_class,
  sum(oi.quantity_sold) quantity,
  date_trunc(month, sold_date) sold_month,
  o.channel
FROM
  fact.order_item oi
  INNER JOIN runway_customers USING (customer_id_edw)
  left join fact.orders o using (order_id_edw)
  left join dim.product p using (product_id_edw)
where product_id_edw is not null 
  and p.merchandise_department = 'SUNGLASSES'
group by all 
order by sold_month,channel 
  ------
  --select * from fact.order_item_detail where
  
--select * from dim.product where merchandise_class is not null