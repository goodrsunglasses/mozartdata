SELECT
  orders.order_id_edw order_number,
  orders.order_id_shopify,
  shopify_line.fulfillment_status shopify_status,
  stord_orders.status stord_status,
  stord_orders.shipped_at,
  fulfil_order.order_ids,
  fact_orders.fulfillment_date,
  fact_orders.quantity_booked_shopify
FROM
  dim.orders orders
  LEFT OUTER JOIN fact.shopify_order_line shopify_line ON shopify_line.order_id_shopify = orders.order_id_shopify
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 stord_orders ON stord_orders.order_id = orders.stord_id
  left outer join fact.fulfillment_orders fulfil_order on fulfil_order.hashed_orderid= stord_orders.order_id
  left outer join fact.orders fact_orders on fact_orders.order_id_edw = orders.order_id_edw
WHERE
  shopify_line.fulfillment_status = 'fulfilled' and shipped_at is not null

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