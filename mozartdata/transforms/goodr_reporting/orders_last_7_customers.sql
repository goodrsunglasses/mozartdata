WITH
  cust_tier AS (
    SELECT distinct 
      order_count,
      CASE
        WHEN order_count = 1 THEN 'New'
        WHEN order_count BETWEEN 2 and 5 THEN 'Existing'
        WHEN order_count >= 5 THEN 'Fan'
        ELSE 'N/A'
      END AS cust_tier
    FROM
      dim.customers
  order by order_count asc
  )
SELECT
  orders.timestamp_tran,
  cust_tier,
  count(orders.order_id_ns) as count_of_orders
FROM
  dim.orders orders
  JOIN dim.customers cust ON orders.cust_id_ns = cust.cust_id_ns
  JOIN cust_tier ON cust.order_count = cust_tier.order_count
WHERE
  to_date(timestamp_tran,'auto') 
  --timestamp_tran 
  >= DATEADD(DAY, -8, CURRENT_DATE())
  AND orders.channel = 'Goodr.com'
GROUP BY
  timestamp_tran,
  cust_tier
order by timestamp_tran asc