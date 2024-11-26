SELECT
  order_id_edw AS order_number,
  booked_date AS order_date,
  channel,
  location,
  case when fulfillment_date is null then 'Not Fulfilled' else null end as unfulfilled
FROM
  fact.orders
WHERE
  channel != 'Key Accounts'
  AND location LIKE '%DC%'
  AND fulfillment_date IS NULL
  AND order_date between '2024-01-01' and current_date()-1--Offset so they don't see stuff from today that they may have fulfilled
and status_flag_edw != True
order by order_date desc