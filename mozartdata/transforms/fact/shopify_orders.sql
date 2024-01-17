SELECT
  name,
  id,
  email,
  subtotal_price,
  total_tax,
  subtotal_price,
  created_at,
  financial_status,
  fulfillment_status,
  total_line_items_price,
  cart_token,
  token,
  checkout_token,
  checkout_id,
  
FROM
  shopify."ORDER" d2c_shop
left outer join shopify.order_line line on line.order_id=d2c_shop.id
left outer join shopify.order_tag tag on tag.order_id=d2c_shop.id