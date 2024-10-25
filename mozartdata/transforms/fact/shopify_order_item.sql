SELECT
  o.order_id_edw,
  o.order_id_shopify,
  o.store,
  line.order_line_id_shopify,
  line.product_id_shopify,
  line.sku as product_id_edw,
  line.sku,
  line.display_name,
  line.price as rate,
  line.quantity as quantity_booked,
  line.quantity - line.fulfillable_quantity as quantity_sold,
  line.fulfillable_quantity as quantity_unfulfilled,
  line.price * line.quantity as amount_booked,
  line.price * (line.quantity - line.fulfillable_quantity) as amount_sold,
  sum(coalesce(da.amount,0)) as amount_discount,
  line.fulfillment_status
FROM
  staging.shopify_orders o
  LEFT OUTER JOIN staging.shopify_order_line line ON line.order_id_shopify = o.order_id_shopify and line.store = o.store
  LEFT OUTER JOIN staging.shopify_discount_allocation da ON da.order_line_id = line.order_line_id_shopify and da.store = o.store
  LEFT OUTER JOIN dim.product p ON p.product_id_edw = line.sku
  GROUP BY ALL
