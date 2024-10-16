SELECT
  order_id_edw,
  channel,
  ord.customer_id_ns,
  customer_name,
  ord.tier,
  location,
  booked_date,
  shipping_window_start_date,
  shipping_window_end_date,
  quantity_booked,
 CASE 
        WHEN CURRENT_DATE BETWEEN shipping_window_start_date AND shipping_window_end_date 
        THEN TRUE 
        ELSE FALSE 
    END AS shipping_window_boolean
FROM
  fact.orders ord 
  left outer join fact.customer_ns_map map on map.customer_id_ns = ord.customer_id_ns
WHERE
  channel = 'Key Accounts'
and shipping_window_boolean