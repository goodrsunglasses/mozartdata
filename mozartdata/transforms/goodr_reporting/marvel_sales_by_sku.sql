with orders as (
SELECT
  p.sku,
  p.display_name as name,
  o.sold_date as transaction_date,
  o.order_id_edw,
  p.family,
  p.collection,
  SUM(oi.quantity_sold) as quantity_sold,
  round(sum(oi.cost_estimate)/SUM(oi.quantity_sold),2) as gross_unit_price,
  SUM(oi.amount_revenue_sold) as gross_sales_amount,
  sum(oi.amount_discount_sold) as discount_deductions,
  sum(oi.amount_product_refunded) as refund_deductions,
  sum(oi.gross_profit_estimate) as net_sales_amount,
  c.customer_name,
  o.channel
FROM fact.order_item oi 
LEFT JOIN fact.orders o on o.order_id_edw = oi.order_id_edw
LEFT JOIN dim.product p on p.sku = oi.sku
LEFT JOIN fact.customer_ns_map c on o.customer_id_ns = c.customer_id_ns
WHERE (collection like '%MARVEL%' OR collection like '%AVENGERS%') and family = 'LICENSING'
group by all
), address as 
(
SELECT DISTINCT
  ol.order_id_edw
, coalesce(ifa.country,isa.country,csa.country,'UNKNOWN') shipping_country
FROM
  orders o
INNER JOIN
  fact.order_line ol
  on o.order_id_edw = ol.order_id_edw
LEFT JOIN
  netsuite.transaction t
  on ol.transaction_id_ns = t.id
  left join
    netsuite.itemfulfillmentshippingaddress ifa
  on ifa.nkey = t.shippingaddress
  and ol.record_type = 'itemfulfillment'
  left join
    netsuite.invoiceshippingaddress isa
    on isa.nkey = t.shippingaddress
    and ol.record_type = 'invoice'
  left join
    netsuite.cashsaleshippingaddress csa
    on csa.nkey = t.shippingaddress
    and ol.record_type = 'cashsale'
  where ol.record_type in ('itemfulfillment','invoice','cashsale')
)
select 
  o.* 
, a.shipping_country
from
  orders o
left join
  address a
  on o.order_id_edw= a.order_id_edw