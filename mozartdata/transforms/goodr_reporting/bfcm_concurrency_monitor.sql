--Primary timestamp "key" will be from shopify
SELECT
  DATE_TRUNC('HOUR', coalesce(timestamp_shopify, timestamp_ns)) AS hour_of_day, --The idea with this is to create a mutally exclusive "Universal" timestamp because if an order isn't in Shopify, like KA and Amazon, it will be in NS 
  coalesce(channel_shopify, channel_ns) AS channel,
  count(order_id_edw) total_orders,
  avg(difference_shopify_ns) difference_shopify_ns_avg,
  avg(difference_shopify_stord) difference_shopify_stord_avg,
  avg(difference_stord_ns) difference_stord_ns_avg,
  avg(shopify_click_stord_ship) shopify_click_stord_ship_avg,
  max(difference_shopify_ns) difference_shopify_ns_max,
  max(difference_shopify_stord) difference_shopify_stord_max,
  max(difference_stord_ns) difference_stord_ns_max,
  max(shopify_click_stord_ship) shopify_click_stord_ship_max
FROM
  fact.order_concurrency_monitor monitor
WHERE
  hour_of_day >= '2024-01-01T00:00:00-00:00'
GROUP BY
  ALL