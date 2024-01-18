SELECT distinct
  d2c_shop.name order_id_edw,
  d2c_shop.id shopify_id,
  line.*
FROM
  shopify."ORDER" d2c_shop
  LEFT OUTER JOIN shopify.order_line line ON line.order_id = d2c_shop.id