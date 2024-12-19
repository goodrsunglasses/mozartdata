/*
Expanse Due Dilligence
12/19/2024
# of orders
# of new customers

*/

SELECT
  date_trunc(month, o.sold_date) order_month
, store as channel
, count(*) order_count
, count(c.first_order_id_edw_shopify) new_customers
from
  fact.shopify_orders o
left join
  fact.customers c
  on o.order_id_edw = c.first_order_id_edw_shopify
group by all