SELECT
  detail.order_id_edw,
  detail.channel,
  detail.location AS location_id,
  loc.full_name AS location_name,
  detail.customer_id_ns,
  map.customer_name,
  detail.transaction_date,
  detail.product_id_edw,
  sum(detail.quantity_backordered) total_backordered
FROM
  fact.order_item_detail detail
  LEFT OUTER JOIN dim.location loc ON loc.location_id_ns = detail.location
  left outer join fact.customer_ns_map map on map.customer_id_edw = detail.customer_id_edw
WHERE
  record_type = 'salesorder'
  AND quantity_backordered > 0
GROUP BY
  ALL