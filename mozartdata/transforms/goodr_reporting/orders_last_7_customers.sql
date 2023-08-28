SELECT
  *
FROM dim.orders
  JOIN dim.cusotmers on cust_id_ns.orders = ns_
WHERE timestamp_tran >= dateadd(day,-7,current_date()) AND channel = 'Goodr.com'