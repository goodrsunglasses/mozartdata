SELECT
  shop_order.name as order_num,
  status,
  province,
  city,
  zip,
  country,
  estimated_delivery_at,
  happened_at,
  message
FROM
  shopify.fulfillment_event fulfill_event
  LEFT OUTER JOIN shopify."ORDER" shop_order ON shop_order.id = fulfill_event.order_id
order by name,happened_at asc