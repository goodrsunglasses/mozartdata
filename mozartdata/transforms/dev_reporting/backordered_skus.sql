SELECT
  detail.order_id_edw,
  detail.channel,
  detail.location AS location_id,
  loc.full_name AS location_name,
  detail.customer_id_ns,
  map.customer_name,
  detail.transaction_date,
  detail.product_id_edw,
  sum(detail.quantity_backordered) total_backordered,
  max(shipping_window_start_date) AS shipping_window_start_date,
  max(shipping_window_end_date) AS shipping_window_end_date
FROM
  fact.order_item_detail detail
  LEFT OUTER JOIN dim.location loc ON loc.location_id_ns = detail.location
  LEFT OUTER JOIN fact.customer_ns_map map ON map.customer_id_edw = detail.customer_id_edw
  LEFT OUTER JOIN fact.order_line line ON line.order_id_ns = detail.order_id_ns
WHERE
  detail.record_type = 'salesorder'
  AND detail.quantity_backordered > 0
GROUP BY
  ALL