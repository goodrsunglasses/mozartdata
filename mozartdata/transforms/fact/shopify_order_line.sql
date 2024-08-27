SELECT DISTINCT
  d2c_shop.name order_id_edw,
  d2c_shop.id order_id_shopify,
  'Goodr.com' AS store,
  d2c_shop.email,
  d2c_shop.total_line_items_price as amount_booked,
  ship.price as shipping_sold,
  d2c_shop.total_tax as tax_sold,
  d2c_shop.total_price as amount_sold,
  d2c_shop.total_discounts as amount_discount,
  d2c_shop.created_at as order_created_timestamp,
  DATE(d2c_shop.created_at) as order_created_date,
  CONVERT_TIMEZONE('America/Los_Angeles', d2c_shop.created_at) AS order_created_timestamp_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', d2c_shop.created_at)) AS order_created_date_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', d2c_shop.created_at)) AS sold_date,
  d2c_shop.financial_status,
  d2c_shop.fulfillment_status,
  d2c_shop.total_line_items_price,
  d2c_shop.cart_token,
  d2c_shop.token,
  d2c_shop.checkout_token,
  d2c_shop.checkout_id as checkout_id_shopify,
  SUM(quantity) over (
    PARTITION BY
      line.order_id
  ) quantity_sold
FROM
  shopify."ORDER" d2c_shop
  LEFT OUTER JOIN shopify.order_line line ON line.order_id = d2c_shop.id
  LEFT OUTER JOIN shopify.order_shipping_line ship ON ship.order_id = d2c_shop.id
UNION ALL
SELECT DISTINCT
  b2b_shop.name order_id_edw,
  b2b_shop.id order_id_shopify,
  'Specialty' AS store,
  b2b_shop.email,
  b2b_shop.total_line_items_price as amount_booked,
  ship.price as shipping_sold,
  b2b_shop.total_tax as tax_sold,
  b2b_shop.total_price as amount_sold,
  b2b_shop.total_discounts as amount_discount,
  b2b_shop.created_at as order_created_timestamp,
  DATE(b2b_shop.created_at) as order_created_date,
  CONVERT_TIMEZONE('America/Los_Angeles', b2b_shop.created_at) AS order_created_timestamp_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', b2b_shop.created_at)) AS order_created_date_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', b2b_shop.created_at)) AS sold_date,
  b2b_shop.financial_status,
  b2b_shop.fulfillment_status,
  b2b_shop.total_line_items_price,
  b2b_shop.cart_token,
  b2b_shop.token,
  b2b_shop.checkout_token,
  b2b_shop.checkout_id as checkout_id_shopify,
  SUM(quantity) over (
    PARTITION BY
      line.order_id
  ) quantity_sold
FROM
  specialty_shopify."ORDER" b2b_shop
  LEFT OUTER JOIN specialty_shopify.order_line line ON line.order_id = b2b_shop.id
  LEFT OUTER JOIN specialty_shopify.order_shipping_line ship ON ship.order_id = b2b_shop.id
UNION ALL
SELECT DISTINCT
  d2c_can_shop.name order_id_edw,
  d2c_can_shop.id order_id_shopify,
  'Canada D2C' AS store,
  d2c_can_shop.email,
  d2c_can_shop.total_line_items_price as amount_booked,
  ship.price as shipping_sold,
  d2c_can_shop.total_tax as tax_sold,
  d2c_can_shop.total_price as amount_sold,
  d2c_can_shop.total_discounts as amount_discount,
  d2c_can_shop.created_at as order_created_timestamp,
  DATE(d2c_can_shop.created_at) as order_created_date,
  CONVERT_TIMEZONE('America/Los_Angeles', d2c_can_shop.created_at) AS order_created_timestamp_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', d2c_can_shop.created_at)) AS order_created_date_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', d2c_can_shop.created_at)) AS sold_date,
  d2c_can_shop.financial_status,
  d2c_can_shop.fulfillment_status,
  d2c_can_shop.total_line_items_price,
  d2c_can_shop.cart_token,
  d2c_can_shop.token,
  d2c_can_shop.checkout_token,
  d2c_can_shop.checkout_id as checkout_id_shopify,
  SUM(quantity) over (
    PARTITION BY
      line.order_id
  ) quantity_sold
FROM
  goodr_canada_shopify."ORDER" d2c_can_shop
  LEFT OUTER JOIN goodr_canada_shopify.order_line line ON line.order_id = d2c_can_shop.id
  LEFT OUTER JOIN goodr_canada_shopify.order_shipping_line ship ON ship.order_id = d2c_can_shop.id
UNION ALL
SELECT DISTINCT
  b2b_can_shop.name order_id_edw,
  b2b_can_shop.id order_id_shopify,
  'Specialty Canada' AS store,
  b2b_can_shop.email,
  b2b_can_shop.total_line_items_price as amount_booked,
  ship.price as shipping_sold,
  b2b_can_shop.total_tax as tax_sold,
  b2b_can_shop.total_price as amount_sold,
  b2b_can_shop.total_discounts as amount_discount,
  b2b_can_shop.created_at as order_created_timestamp,
  DATE(b2b_can_shop.created_at) as order_created_date,
  CONVERT_TIMEZONE('America/Los_Angeles', b2b_can_shop.created_at) AS order_created_timestamp_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', b2b_can_shop.created_at)) AS order_created_date_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', b2b_can_shop.created_at)) AS sold_date,
  b2b_can_shop.financial_status,
  b2b_can_shop.fulfillment_status,
  b2b_can_shop.total_line_items_price,
  b2b_can_shop.cart_token,
  b2b_can_shop.token,
  b2b_can_shop.checkout_token,
  b2b_can_shop.checkout_id as checkout_id_shopify,
  SUM(quantity) over (
    PARTITION BY
      line.order_id
  ) quantity_sold
FROM
  sellgoodr_canada_shopify."ORDER" b2b_can_shop
  LEFT OUTER JOIN sellgoodr_canada_shopify.order_line line ON line.order_id = b2b_can_shop.id
  LEFT OUTER JOIN sellgoodr_canada_shopify.order_shipping_line ship ON ship.order_id = b2b_can_shop.id
UNION ALL
SELECT DISTINCT
  goodrwill.name order_id_edw,
  goodrwill.id order_id_shopify,
  'Goodrwill' AS store,
  goodrwill.email,
  goodrwill.total_line_items_price as amount_booked,
  ship.price as shipping_sold,
  goodrwill.total_tax as tax_sold,
  goodrwill.total_price as amount_sold,
  goodrwill.total_discounts as amount_discount,
  goodrwill.created_at as order_created_timestamp,
  DATE(goodrwill.created_at) as order_created_date,
  CONVERT_TIMEZONE('America/Los_Angeles', goodrwill.created_at) AS order_created_timestamp_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', goodrwill.created_at)) AS order_created_date_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', goodrwill.created_at)) AS sold_date,
  goodrwill.financial_status,
  goodrwill.fulfillment_status,
  goodrwill.total_line_items_price,
  goodrwill.cart_token,
  goodrwill.token,
  goodrwill.checkout_token,
  goodrwill.checkout_id as checkout_id_shopify,
  SUM(quantity) over (
    PARTITION BY
      line.order_id
  ) quantity_sold
FROM
  goodrwill_shopify."ORDER" goodrwill
  LEFT OUTER JOIN goodrwill_shopify.order_line line ON line.order_id = goodrwill.id
  LEFT OUTER JOIN goodrwill_shopify.order_shipping_line ship ON ship.order_id = goodrwill.id
UNION ALL
SELECT DISTINCT
  goodrwill.name order_id_edw,
  goodrwill.id order_id_shopify,
  'Goodrwill' AS store,
  goodrwill.email,
  goodrwill.total_line_items_price as amount_booked,
  ship.price as shipping_sold,
  goodrwill.total_tax as tax_sold,
  goodrwill.total_price as amount_sold,
  goodrwill.total_discounts as amount_discount,
  goodrwill.created_at as order_created_timestamp,
  DATE(goodrwill.created_at) as order_created_date,
  CONVERT_TIMEZONE('America/Los_Angeles', goodrwill.created_at) AS order_created_timestamp_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', goodrwill.created_at)) AS order_created_date_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', goodrwill.created_at)) AS sold_date,
  goodrwill.financial_status,
  goodrwill.fulfillment_status,
  goodrwill.total_line_items_price,
  goodrwill.cart_token,
  goodrwill.token,
  goodrwill.checkout_token,
  goodrwill.checkout_id as checkout_id_shopify,
  SUM(quantity) over (
    PARTITION BY
      line.order_id
  ) quantity_sold
FROM
  cabana."ORDER" goodrwill
  LEFT OUTER JOIN cabana.order_line line ON line.order_id = goodrwill.id
  LEFT OUTER JOIN cabana.order_shipping_line ship ON ship.order_id = goodrwill.id