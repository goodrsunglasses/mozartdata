SELECT DISTINCT
  d2c_shop.name order_id_edw,
  d2c_shop.id order_id_shopify,
  'Goodr.com' AS store,
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
UNION ALL
SELECT DISTINCT
  b2b_shop.name order_id_edw,
  b2b_shop.id order_id_shopify,
  'Specialty' AS store,
  b2b_shop.email,
  b2b_shop.subtotal_price,
  b2b_shop.total_tax,
  b2b_shop.created_at,
  b2b_shop.financial_status,
  b2b_shop.fulfillment_status,
  b2b_shop.total_line_items_price,
  b2b_shop.cart_token,
  b2b_shop.token,
  b2b_shop.checkout_token,
  b2b_shop.checkout_id,
  SUM(quantity) over (
    PARTITION BY
      order_id
  ) total_quantity
FROM
  specialty_shopify."ORDER" b2b_shop
  LEFT OUTER JOIN specialty_shopify.order_line line ON line.order_id = b2b_shop.id