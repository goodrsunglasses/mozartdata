SELECT
  p.sku,
  p.display_name as name,
  o.sold_date as transaction_date,
  o.order_id_edw,
  p.family,
  p.collection,
  SUM(oi.quantity_sold) as quantity_sold,
  oi.rate_sold as gross_unit_price,
  SUM(oi.amount_revenue_sold) as gross_sales_amount,
  sum(oi.amount_discount_sold) as discount_deductions,
  sum(oi.gross_profit_estimate),
  c.customer_name,
  o.channel
FROM fact.order_item oi 
LEFT JOIN fact.orders o on o.order_id_edw = oi.order_id_edw
LEFT JOIN dim.product p on p.sku = oi.sku
LEFT JOIN fact.customer_ns_map c on o.customer_id_ns = c.customer_id_ns
WHERE (collection like '%MARVEL%' OR collection like '%AVENGERS%') and family = 'LICENSING'
group by all