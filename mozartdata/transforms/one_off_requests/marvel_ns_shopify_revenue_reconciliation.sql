with orders as (
SELECT distinct
--   p.sku,
--   p.display_name as name,
--   coalesce(o.sold_date,o.booked_date) as transaction_date,
  o.order_id_edw,
--   p.family,
--   p.collection,
  SUM(oi.quantity_booked) as quantity_sold,
  round(sum(oi.rate_sold)/SUM(oi.quantity_sold),2) as gross_unit_price,
  SUM(oi.amount_revenue_sold) as gross_sales_amount,
  sum(oi.amount_discount_sold) as discount_deductions,
  sum(oi.amount_product_refunded) as refund_deductions,
  SUM(oi.amount_revenue_sold)-sum(oi.amount_discount_sold)-sum(oi.amount_product_refunded) as net_sales_amount,
  o.amount_revenue_sold order_revenue_sold,
  o.amount_revenue_refunded order_revenue_refunded
--   c.customer_name,
--   o.channel
FROM fact.order_item oi
LEFT JOIN fact.orders o on o.order_id_edw = oi.order_id_edw
LEFT JOIN dim.product p on p.sku = oi.sku
-- LEFT JOIN fact.customer_ns_map c on o.customer_id_ns = c.customer_id_ns
WHERE (collection like '%MARVEL%' OR collection like '%AVENGERS%') and family = 'LICENSING'
--and oi.quantity_sold != oi.quantity_booked
group by all
), shopify_orders as
(
  select
      o.order_id_edw
  , so.amount_revenue_sold
  , so.amount_sold
  , so.amount_discount
  , sr.amount_refund_subtotal
  , sr.amount_standard_discount
  , sr.amount_yotpo_discount
  from
    fact.shopify_orders so
  inner join
    orders o
  on so.order_id_edw = o.order_id_edw
  left join
    (  select
 oi.order_id_edw
, sum(coalesce(oi.amount_refund_subtotal,0)) as amount_refund_subtotal
, sum(oi.amount_standard_discount) amount_standard_discount
  , sum(oi.amount_yotpo_discount) amount_yotpo_discount
from
  fact.shopify_order_item oi
group by all

      ) sr
  on sr.order_id_edw = so.order_id_edw

)
SELECT
  o.order_id_edw
, o.quantity_sold as marvel_sku_quantity_sold
, o.gross_sales_amount as marvel_sku_gross_sales_amount
, o.net_sales_amount as marvel_sku_net_sales_amount
, o.order_revenue_sold as NS_amount_revenue_sold
-- , o.order_revenue_refunded
, so.amount_revenue_sold as shopify_amount_revenue_sold
-- , so.amount_sold as shopify_amount_sold
-- , so.amount_discount as shopify_amount_discount
-- , so.amount_refund_subtotal as shopify_amount_refund_subtotal
-- , so.amount_standard_discount as amount_standard_discount
-- , so.amount_yotpo_discount as amount_yotpo_discount
from
  orders o
left join
  shopify_orders so
  using (order_id_edw)