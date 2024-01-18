SELECT distinct
  d2c_shop.name,
  d2c_shop.id,
  d2c_shop.email,
  d2c_shop.subtotal_price,
  d2c_shop.total_tax,
  d2c_shop.created_at,
  d2c_shop.financial_status,
  d2c_shop.fulfillment_status,
  d2c_shop.total_line_items_price,
  d2c_shop.cart_token,
  d2c_shop.token,
  d2c_shop.checkout_token,
  d2c_shop.checkout_id,
  SUM(quantity) over (
    PARTITION BY
      order_id
  ) total_quantity
FROM
  shopify."ORDER" d2c_shop
  LEFT OUTER JOIN shopify.order_line line ON line.order_id = d2c_shop.id
  -- left outer join shopify.order_tag tag on tag.order_id=d2c_shop.id