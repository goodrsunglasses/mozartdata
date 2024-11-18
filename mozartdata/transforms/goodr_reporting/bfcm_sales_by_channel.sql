SELECT
  s.sold_date
, s.channel
, s.bfcm_period
, SUM(s.order_count)           AS order_count
, SUM(s.quantity_booked)       AS quantity_booked
, SUM(s.amount_product)        AS amount_product
, SUM(s.amount_sales)          AS amount_sales
, SUM(s.amount_yotpo_discount) AS amount_yotpo_discount
, sum(s.amount_refunded) as amount_refunded
, SUM(s.amount_sales) - sum(s.amount_refunded) as amount_net_sales

FROM
  goodr_reporting.bfcm_sales_by_sku s
GROUP BY ALL