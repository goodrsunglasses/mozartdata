SELECT
  p.item_id_ns,
  p.display_name,
  p.family,
  p.collection,
  MIN(p.d2c_launch_date) AS earliest_d2c_launch_date,
  MIN(o.order_date_pst) AS earliest_sale,
  o.channel
FROM
  draft_dim.product p
  LEFT JOIN fact.order_item oi ON p.item_id_ns = oi.item_id_ns
  LEFT JOIN fact.orders o ON o.order_id_edw = oi.order_id_edw
WHERE
  o.channel = 'Goodr.com'
GROUP BY
  p.item_id_ns,
  o.channel,
  p.family,
  p.collection,
  p.display_name;