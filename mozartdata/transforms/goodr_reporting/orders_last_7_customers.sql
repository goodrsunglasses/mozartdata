SELECT
*
FROM dim.orders
WHERE date_trunc('day', timestamp_tran) > dateadd(day, -7, current_date()) and channel = 'goodr.com'