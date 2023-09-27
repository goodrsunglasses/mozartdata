SELECT
  DATE_TRUNC('DAY', timestamp_transaction_pst)::DATE AS transaction_date,
  channel,
  COUNT(*) AS orders_count,
  sum(quantity_sold) as units_sold
FROM
  dim.orders
WHERE
  DATE_TRUNC('DAY', timestamp_transaction_pst)::DATE >= CURRENT_DATE() - INTERVAL '15 DAY'
  AND DATE_TRUNC('DAY', timestamp_transaction_pst)::DATE < CURRENT_DATE()
  and is_exchange = 'false'
  and channel <> 'Key Account' --- removing key account while we fix it in orders
GROUP BY
  transaction_date,
  channel
ORDER BY
  transaction_date desc