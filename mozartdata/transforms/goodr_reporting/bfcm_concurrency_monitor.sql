--Primary timestamp "key" will be from shopify
SELECT
  CASE
    WHEN EXTRACT(
      HOUR
      FROM
        coalesce(timestamp_shopify, timestamp_ns)
    ) < 12 THEN DATE_TRUNC('DAY', coalesce(timestamp_shopify, timestamp_ns))
    ELSE TIMESTAMPADD(
      'HOUR',
      12,
      DATE_TRUNC('DAY', coalesce(timestamp_shopify, timestamp_ns))
    )
  END AS gabby_super_specific_logic_half_of_day,
  DATE_TRUNC('HOUR', coalesce(timestamp_shopify, timestamp_ns)) AS hour_of_day, --The idea with this is to create a mutally exclusive "Universal" timestamp because if an order isn't in Shopify, like KA and Amazon, it will be in NS 
  coalesce(channel_shopify, channel_ns) AS channel,
  count(order_id_edw) total_orders,
  avg(difference_shopify_ns_in_minutes) difference_shopify_ns_avg,
  avg(difference_shopify_stord_in_minutes) difference_shopify_stord_avg,
  avg(difference_stord_ns_in_minutes) difference_stord_ns_avg,
  avg(shopify_click_stord_ship_in_minutes) shopify_click_stord_ship_avg,
  max(difference_shopify_ns_in_minutes) difference_shopify_ns_max,
  max(difference_shopify_stord_in_minutes) difference_shopify_stord_max,
  max(difference_stord_ns_in_minutes) difference_stord_ns_max,
  max(shopify_click_stord_ship_in_minutes) shopify_click_stord_ship_max
FROM
  fact.order_concurrency_monitor monitor
WHERE
  hour_of_day >= '2024-11-26T00:00:00-00:00' and hour_of_day <= '2024-12-03T00:00:00-00:00' and channel not in('Customer Service','Goodrwill','Amazon Canada','Amazon')
GROUP BY
  ALL