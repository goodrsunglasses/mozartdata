SELECT
  DATE_TRUNC('DAY', timestamp_transaction_pst)::DATE AS transaction_date,
  channel,
  COUNT(order_id_edw) AS orders_count,
  sum(quantity_sold) as units_sold,
  ROUND(SUM(amount_sold), 2) as total_amount,
  b2b_d2c
FROM
  fact.orders
WHERE
  DATE_TRUNC('DAY', timestamp_transaction_pst)::DATE >= CURRENT_DATE() - INTERVAL '15 DAY'
  AND DATE_TRUNC('DAY', timestamp_transaction_pst)::DATE < CURRENT_DATE()
  and is_exchange = 'false'
--  and channel not in ('Key Account', 'Global','Customer Service') --- removing key account and global while we fix it in orders
GROUP BY
  transaction_date,
  channel,
  b2b_d2c
ORDER BY
  transaction_date desc