SELECT
  order_id_edw,
  channel,
  customer_name,
  ord.tier,
  location,
  booked_date,
  fulfillment_date,
  shipping_window_start_date,
  shipping_window_end_date,
  quantity_booked,
  CASE
    WHEN CURRENT_DATE BETWEEN shipping_window_start_date AND shipping_window_end_date  THEN TRUE
    ELSE FALSE
  END AS shipping_window_boolean,
  case when fulfillment_date is null 
FROM
  fact.orders ord
  LEFT OUTER JOIN fact.customer_ns_map map ON map.customer_id_ns = ord.customer_id_ns
WHERE
  channel = 'Key Accounts'
  AND location NOT LIKE '%Stord%'
and booked_date>='2024-01-01'