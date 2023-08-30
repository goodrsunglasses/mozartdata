WITH
  cust_tier AS (
    SELECT distinct 
      order_count,
      CASE
        WHEN order_count = 1 THEN 'NEW'
        WHEN order_count BETWEEN 2 and 5 THEN 'EXISTING'
        WHEN order_count >= 5 THEN 'FAN'
        ELSE 'N/A'
      END AS cust_tier
    FROM
      dim.customers
  order by order_count asc
  )
SELECT
    DATE(timestamp_tran) as converted_timestamp,
  cust_tier,
  count(orders.order_id_ns) as count_of_orders
FROM
  dim.orders orders
  JOIN dim.customers cust ON orders.cust_id_ns = cust.cust_id_ns
  JOIN cust_tier ON cust.order_count = cust_tier.order_count
WHERE
  converted_timestamp >= DATEADD(DAY, -7, CURRENT_DATE())
  AND orders.channel = 'Goodr.com'
GROUP BY
  converted_timestamp,
  cust_tier
order by converted_timestamp asc