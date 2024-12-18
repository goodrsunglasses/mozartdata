WITH
  pack_times AS (
    SELECT
      retailer,
      CASE
        WHEN retailer LIKE 'Dick%' THEN 'Dicks Sporting Goods'
        WHEN retailer LIKE 'Duluth%' THEN 'Duluth Trading Co.'
        WHEN retailer LIKE 'Running%' THEN 'Running Room Canada Inc.'
        WHEN retailer LIKE 'Specialized%' THEN 'Specialized Miami Wynwood'
        WHEN retailer LIKE 'Road%' THEN 'Road Runner Sports'
        WHEN retailer LIKE 'Scheels%' THEN 'Scheels Fargo'
        WHEN retailer LIKE 'Dunham%' THEN 'Dunham''s Sports'
        ELSE retailer
      END AS fixed_retailer,
      total_additional_time_per_order_in_minutes_ AS per_order,
      total_per_100_units_in_minutes_ AS per_100_units
    FROM
      google_sheets.dc_calc_times
  )
SELECT
  order_id_edw,
  channel,
  CASE
    WHEN customer_name LIKE 'Fleet Feet%' THEN 'Fleet Feet'
    ELSE customer_name
  END AS normalized_name,
  per_order,
  per_100_units,
  ord.tier,
  location,
  booked_date,
  fulfillment_date,
  shipping_window_start_date,
  shipping_window_end_date,
  quantity_booked,
  round(
    ((quantity_booked / 100) * per_100_units) + per_order,
    2
  ) AS total_time_minutes,
  CASE
    WHEN CURRENT_DATE BETWEEN shipping_window_start_date AND shipping_window_end_date  THEN TRUE
    ELSE FALSE
  END AS shipping_window_boolean,
  CASE
    WHEN fulfillment_date IS NOT NULL THEN TRUE
    ELSE FALSE
  END AS fullfilled_boolean
FROM
  fact.orders ord
  LEFT OUTER JOIN fact.customer_ns_map map ON map.customer_id_ns = ord.customer_id_ns
  LEFT OUTER JOIN pack_times ON lower(pack_times.fixed_retailer) = lower(normalized_name)
WHERE
  channel = 'Key Accounts'
  AND location NOT LIKE '%Stord%'
  AND booked_date >= '2024-01-01'
  AND ord.order_id_edw not like 'BPO%'