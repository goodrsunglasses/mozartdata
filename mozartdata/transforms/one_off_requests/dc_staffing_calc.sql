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
        WHEN retailer LIKE 'Glik%' THEN 'Glik''s'
   WHEN retailer LIKE 'Glik%' THEN 'Glik''s'
   WHEN retailer LIKE 'Glik%' THEN 'Glik''s'
   WHEN retailer LIKE 'Glik%' THEN 'Glik''s'
   WHEN retailer LIKE 'Glik%' THEN 'Glik''s'
   WHEN retailer LIKE 'Glik%' THEN 'Glik''s'
        ELSE retailer
      END AS fixed_retailer
    FROM
      google_sheets.dc_calc_times
  )
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
  CASE
    WHEN fulfillment_date IS NOT NULL THEN TRUE
    ELSE FALSE
  END AS fullfilled_boolean
FROM
  fact.orders ord
  LEFT OUTER JOIN fact.customer_ns_map map ON map.customer_id_ns = ord.customer_id_ns
WHERE
  channel = 'Key Accounts'
  AND location NOT LIKE '%Stord%'
  AND booked_date >= '2024-01-01'