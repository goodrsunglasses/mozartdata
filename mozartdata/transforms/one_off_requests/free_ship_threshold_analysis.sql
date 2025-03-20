--- count of orders at different qty levels and revenue brackets to compare for free ship thresholds 

SELECT
  date(date_trunc(month, sold_Date)) as sold_month,
  channel,
  count(order_id_edw) as orders_total,
  count(CASE WHEN quantity_sold = 1 THEN order_id_edw END) AS orders_with_1,
  count(CASE WHEN quantity_sold = 2 THEN order_id_edw END) AS orders_with_2,
  count(CASE WHEN quantity_sold = 3 THEN order_id_edw END) AS orders_with_3,
  count(CASE WHEN quantity_sold = 4 THEN order_id_edw END) AS orders_with_4,
  count(CASE WHEN quantity_sold >= 5 THEN order_id_edw END) AS orders_with_5plus
FROM
  fact.orders
where channel in ('Goodr.com', 'goodr.ca')
  and sold_month >= '2024-01-01'
group by all
order by 2,1

---------------------
with st_amount as (
  select 
    order_id_edw,
    (amount_revenue_sold - amount_shipping_sold) as st_amount,   --- only includes the things that would be included to calculate shipping threshold 
    date(date_trunc(month, sold_Date)) as sold_month,
    channel
  from 
    fact.orders
)
SELECT
  sold_month,
  channel,
  count(order_id_edw) as orders_total,
  count(CASE WHEN st_amount >= 50 and st_amount < 55 THEN order_id_edw END) AS orders_50,
  count(CASE WHEN st_amount >= 55 and st_amount < 60 THEN order_id_edw END) AS orders_55,
  count(CASE WHEN st_amount >= 60 and st_amount < 65 THEN order_id_edw END) AS orders_60,
  count(CASE WHEN st_amount >= 65 and st_amount < 70 THEN order_id_edw END) AS orders_65,
  count(CASE WHEN st_amount >= 70 and st_amount < 75 THEN order_id_edw END) AS orders_70,
  count(CASE WHEN st_amount >= 75 and st_amount < 80 THEN order_id_edw END) AS orders_75,
  count(CASE WHEN st_amount >= 80 and st_amount < 85 THEN order_id_edw END) AS orders_80,
  count(CASE WHEN st_amount >= 85 and st_amount < 90 THEN order_id_edw END) AS orders_85,
  count(CASE WHEN st_amount >= 90 and st_amount < 95 THEN order_id_edw END) AS orders_90,
  count(CASE WHEN st_amount >= 95 and st_amount < 100 THEN order_id_edw END) AS orders_95,
  count(CASE WHEN st_amount >= 100 THEN order_id_edw END) AS orders_100plus
FROM
  st_amount
where channel in ('Goodr.com', 'goodr.ca')
  and sold_month >= '2024-01-01'
group by all
order by 2, 1

------------------
with st_50to60 as (
  select 
    order_id_edw,
    (amount_revenue_sold - amount_shipping_sold) as st_amount,   --- only includes the things that would be included to calculate shipping threshold 
    date(date_trunc(month, sold_Date)) as sold_month,
    channel
  from 
    fact.orders
  where st_amount >= 50 and st_amount < 60
  and  channel = 'Goodr.com'
)
SELECT
  sold_month,
  count(order_id_edw) as orders_total,
  count(order_id_edw) * 5 as new_ship_revenue_5,
FROM
  st_50to60
where  sold_month >= '2024-01-01'
group by all
order by 1




--select * from fact.orders
--select distinct (channel) from fact.orders