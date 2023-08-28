WITH cust_tier as (
  SELECT order_count,
  CASE 
    WHEN order_count = 1 THEN 'New'
    WHEN order_count BETWEEN 2 and 5 THEN 'Existing'
    WHEN order_count >= 10 THEN 'Fan'
    ELSE 'N/A'
  END as cust_tier
  FROM dim.customers)

SELECT
  orders.order_id_ns,
  orders.channel,
  orders.timestamp_tran,
  orders.cust_id_ns,
  cust.order_count as cust_order_count,
  cust_tier
FROM dim.orders orders
  JOIN dim.customers cust on orders.cust_id_ns = cust.cust_id_ns
  JOIN cust_tier on cust.order_count = cust_tier.order_count
WHERE timestamp_tran >= dateadd(day,-7,current_date()) AND orders.channel = 'Goodr.com'