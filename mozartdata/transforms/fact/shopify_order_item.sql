SELECT
  d2c_shop.name order_id_edw,
  d2c_shop.id order_id_shopify,
  'Goodr.com' AS store,
  line.id AS order_line_id,
  product.product_id_edw,
  line.sku,
  line.name,
  line.price as rate,
  line.quantity as quantity_booked,
  line.quantity - line.fulfillable_quantity as quantity_sold,
  line.fulfillable_quantity as quantity_unfulfilled,
  line.price * line.quantity as amount_booked,
  line.price * (line.quantity - line.fulfillable_quantity) as amount_sold,
  line.fulfillment_status
FROM
  shopify."ORDER" d2c_shop
  LEFT OUTER JOIN shopify.order_line line ON line.order_id = d2c_shop.id
  LEFT OUTER JOIN dim.product product ON product.product_id_d2c_shopify = line.product_id
UNION ALL
SELECT
  b2b_shop.name order_id_edw,
  b2b_shop.id order_id_shopify,
  'Specialty' AS store,
  line.id AS order_line_id,
  product.product_id_edw,
  line.sku,
  line.name,
  line.price as rate,
  line.quantity as quantity_booked,
  line.quantity - line.fulfillable_quantity as quantity_sold,
  line.fulfillable_quantity as quantity_unfulfilled,
  line.price * line.quantity as amount_booked,
  line.price * (line.quantity - line.fulfillable_quantity) as amount_sold,
  line.fulfillment_status
FROM
  specialty_shopify."ORDER" b2b_shop
  LEFT OUTER JOIN specialty_shopify.order_line line ON line.order_id = b2b_shop.id
  LEFT OUTER JOIN dim.product product ON product.product_id_b2b_shopify = line.product_id
  UNION ALL
SELECT
  b2b_shop.name order_id_edw,
  b2b_shop.id order_id_shopify,
  'Specialty' AS store,
  line.id AS order_line_id,
  product.product_id_edw,
  line.sku,
  line.name,
  line.price as rate,
  line.quantity as quantity_booked,
  line.quantity - line.fulfillable_quantity as quantity_sold,
  line.fulfillable_quantity as quantity_unfulfilled,
  line.price * line.quantity as amount_booked,
  line.price * (line.quantity - line.fulfillable_quantity) as amount_sold,
  line.fulfillment_status
FROM
  goodrwill_shopify."ORDER" b2b_shop
  LEFT OUTER JOIN goodrwill_shopify.order_line line ON line.order_id = b2b_shop.id
  LEFT OUTER JOIN dim.product product ON product.product_id_b2b_shopify = line.product_id
  UNION ALL
SELECT
  b2b_shop.name order_id_edw,
  b2b_shop.id order_id_shopify,
  'Specialty' AS store,
  line.id AS order_line_id,
  product.product_id_edw,
  line.sku,
  line.name,
  line.price as rate,
  line.quantity as quantity_booked,
  line.quantity - line.fulfillable_quantity as quantity_sold,
  line.fulfillable_quantity as quantity_unfulfilled,
  line.price * line.quantity as amount_booked,
  line.price * (line.quantity - line.fulfillable_quantity) as amount_sold,
  line.fulfillment_status
FROM
  sellgoodr_canada_shopify."ORDER" b2b_shop
  LEFT OUTER JOIN sellgoodr_canada_shopify.order_line line ON line.order_id = b2b_shop.id
  LEFT OUTER JOIN dim.product product ON product.product_id_b2b_shopify = line.product_id
  UNION ALL
SELECT
  b2b_shop.name order_id_edw,
  b2b_shop.id order_id_shopify,
  'Specialty' AS store,
  line.id AS order_line_id,
  product.product_id_edw,
  line.sku,
  line.name,
  line.price as rate,
  line.quantity as quantity_booked,
  line.quantity - line.fulfillable_quantity as quantity_sold,
  line.fulfillable_quantity as quantity_unfulfilled,
  line.price * line.quantity as amount_booked,
  line.price * (line.quantity - line.fulfillable_quantity) as amount_sold,
  line.fulfillment_status
FROM
  goodr_canada_shopify."ORDER" b2b_shop
  LEFT OUTER JOIN goodr_canada_shopify.order_line line ON line.order_id = b2b_shop.id
  LEFT OUTER JOIN dim.product product ON product.product_id_b2b_shopify = line.product_id
  UNION ALL
SELECT
  b2b_shop.name order_id_edw,
  b2b_shop.id order_id_shopify,
  'Specialty' AS store,
  line.id AS order_line_id,
  product.product_id_edw,
  line.sku,
  line.name,
  line.price as rate,
  line.quantity as quantity_booked,
  line.quantity - line.fulfillable_quantity as quantity_sold,
  line.fulfillable_quantity as quantity_unfulfilled,
  line.price * line.quantity as amount_booked,
  line.price * (line.quantity - line.fulfillable_quantity) as amount_sold,
  line.fulfillment_status
FROM
  cabana."ORDER" b2b_shop
  LEFT OUTER JOIN cabana.order_line line ON line.order_id = b2b_shop.id
  LEFT OUTER JOIN dim.product product ON product.product_id_b2b_shopify = line.product_id