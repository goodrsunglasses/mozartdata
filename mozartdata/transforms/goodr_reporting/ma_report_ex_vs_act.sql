SELECT
  order_id_edw,
  ord.customer_id_ns,
  map.customer_name,
  map.customer_number,
  shipping_window_start_date,
  shipping_window_end_date,
  ord.tier,
  booked_date,
  sold_date,
  fulfillment_date,
  rate_booked,
  rate_sold,
  amount_revenue_booked_ns,
  amount_revenue_sold,
  revenue
FROM
  fact.orders ord
  LEFT OUTER JOIN fact.customer_ns_map map ON map.customer_id_ns = ord.customer_id_ns
WHERE
  channel = 'Key Accounts'
  AND booked_date >= '2023-01-01'