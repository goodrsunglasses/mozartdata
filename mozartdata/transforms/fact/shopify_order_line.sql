SELECT DISTINCT
  o.order_id_edw,
  o.order_id_shopify,
  line.order_line_id_shopify,
  line.store,
  line.product_id_shopify,
  line.sku,
  line.display_name,
  line.price as rate,
  line.quantity as quantity_booked,
  line.quantity - line.fulfillable_quantity as quantity_sold,
  line.fulfillable_quantity as quantity_unfulfilled,
  line.price * line.quantity as amount_booked,
  line.price * (line.quantity - line.fulfillable_quantity) as amount_sold,
  sum(coalesce(sdi.amount_total_discount,0)) as amount_total_discount,
  sum(coalesce(sdi.amount_standard_discount,0)) as amount_standard_discount,
  sum(coalesce(sdi.amount_yotpo_discount,0)) as amount_yotpo_discount,
  line.fulfillment_status,
  o.created_at as order_created_timestamp,
  DATE(o.created_at) as order_created_date,
  CONVERT_TIMEZONE('America/Los_Angeles', o.created_at) AS order_created_timestamp_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', o.created_at)) AS order_created_date_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', o.created_at)) AS sold_date
FROM
  staging.shopify_order_line line
  LEFT OUTER JOIN staging.shopify_orders o ON line.order_id_shopify = o.order_id_shopify and line.store = o.store
  LEFT OUTER JOIN staging.shopify_discount_allocation da ON da.order_line_id = line.order_line_id_shopify and da.store = o.store
  LEFT OUTER JOIN fact.shopify_discount_item sdi on sdi.order_line_id_shopify = line.order_line_id_shopify and sdi.store = line.store
GROUP BY ALL