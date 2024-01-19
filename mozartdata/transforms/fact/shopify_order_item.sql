SELECT 
  d2c_shop.name order_id_edw,
  d2c_shop.id order_id_shopify,
  line.id as order_line_id,
  product_id_edw,
  line.name,
  line.price,
  line.quantity,
  line.sku,
  line.fulfillable_quantity,
  line.fulfillment_status
FROM
  shopify."ORDER" d2c_shop
  LEFT OUTER JOIN shopify.order_line line ON line.order_id = d2c_shop.id
  LEFT OUTER JOIN dim.product product ON product.d2c_id_shopify = line.variant_id