SELECT
  p.item_id_ns,
  p.display_name,
  p.family,
  MIN(p.d2c_launch_date) AS earlist_d2c_launch_date,
  MIN(oid.transaction_date_pst) AS earliest_sale,
  o.channel
FROM
  draft_dim.product p
  LEFT JOIN fact.order_item_detail oid ON p.item_id_ns = oid.item_id_ns
  LEFT JOIN fact.orders o ON o.order_id_edw = oid.order_id_edw
WHERE
  o.channel = 'Goodr.com'
GROUP BY
  p.item_id_ns,
  o.channel,
 p.family,
  p.display_name;