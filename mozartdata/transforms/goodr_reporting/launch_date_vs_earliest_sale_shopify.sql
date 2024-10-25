SELECT
  p.item_id_ns,
  p.display_name,
  p.family,
  p.collection,
  p.product_id_edw,
  p.product_id_d2c_shopify,
  MIN(p.d2c_launch_date) AS earliest_d2c_launch_date,
  MIN(p.b2b_launch_date) AS earliest_b2b_launch_date,
  MIN(o.order_created_date) AS earliest_d2c_sale
FROM
  dim.product p
  LEFT JOIN fact.shopify_order_item oi ON p.product_id_edw = oi.product_id_edw
  LEFT JOIN fact.shopify_orders o ON o.order_id_shopify = oi.order_id_shopify
GROUP BY
  p.item_id_ns,
  p.family,
  p.collection,
  p.display_name,
  p.product_id_edw,
  p.product_id_d2c_shopify;