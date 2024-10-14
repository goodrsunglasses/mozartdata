SELECT
  order_id_edw,
  channel,
  customer_id_ns,
  tier,
  location,
  booked_date,
  shipping_window_start_date,
  shipping_window_end_date,
  quantity_booked,
  CASE
    WHEN DATE_TRUNC('WEEK', shipping_window_end_date) = DATE_TRUNC('WEEK', CURRENT_DATE) THEN TRUE
    ELSE FALSE
  END AS is_this_week,
  CASE
    WHEN shipping_window_end_date = CURRENT_DATE THEN TRUE
    ELSE FALSE
  END AS is_today
FROM
  fact.orders ord 
  left outer join fact.customer_ns_map map on map.customer_id_ns = 
WHERE
  channel = 'Key Accounts'
  AND order_id_edw = '4530505893'