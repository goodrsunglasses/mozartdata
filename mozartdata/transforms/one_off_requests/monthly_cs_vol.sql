SELECT
  sum(quantity_fulfilled),
  count(distinct(order_id_ns)),
  channel,
  location,
  date_trunc(month, fulfillment_date) as month
FROM
  fact.orders
WHERE
  channel = 'Customer Service'
group by 
  all