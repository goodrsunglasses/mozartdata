SELECT
  orders.order_id_edw order_number,
  orders.order_id_shopify,
  shopify_line.fulfillment_status shopify_status,
  stord_orders.status stord_status,
  stord_orders.shipped_at,
  fact_orders.fulfillment_date,
  sum(fulfill.total_quantity) stord_fulfilled_quantity,
  fact_orders.quantity_fulfilled quantity_fulfilled_ns
FROM
  dim.orders orders
  LEFT OUTER JOIN fact.shopify_order_line shopify_line ON shopify_line.order_id_shopify = orders.order_id_shopify
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 stord_orders ON stord_orders.order_id = orders.stord_id
  LEFT OUTER JOIN fact.fulfillment_orders fulfil_order ON fulfil_order.hashed_orderid = stord_orders.order_id
  LEFT OUTER JOIN fact.orders fact_orders ON fact_orders.order_id_edw = orders.order_id_edw
  LEFT OUTER JOIN fact.fulfillment fulfill ON fulfill.order_id_edw = orders.order_id_edw
WHERE
  shopify_line.fulfillment_status = 'fulfilled'
  AND shipped_at IS NOT NULL
GROUP BY
  orders.order_id_edw,
  orders.order_id_shopify,
  shopify_line.fulfillment_status,
  stord_orders.status,
  stord_orders.shipped_at,
  fact_orders.fulfillment_date,
  fact_orders.quantity_fulfilled
limit 200
  -- SELECT
  --   *
  -- FROM
  --   dim.orders
  -- WHERE
  --   stord_id IS NOT NULL
  -- SELECT
  --   *
  -- FROM
  --   dim.fulfillment
  -- WHERE
  --   source_system = 'Stord'