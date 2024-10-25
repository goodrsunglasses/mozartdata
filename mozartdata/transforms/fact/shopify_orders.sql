SELECT DISTINCT
  o.order_id_edw,
  o.order_id_shopify,
  o.store,
  o.email,
  o.total_line_items_price as amount_booked,
  ship.price as shipping_sold,
  o.amount_tax_sold as amount_tax_sold,
  o.amount_sold as amount_sold,
  round(o.amount_sold - o.amount_tax_sold - ship.price + o.amount_discount,2) as amount_product_sold,
  round(o.amount_sold - o.amount_tax_sold,2) as amount_revenue_sold,
  o.amount_discount*-1 as amount_discount,
  o.created_at as order_created_timestamp,
  DATE(o.created_at) as order_created_date,
  CONVERT_TIMEZONE('America/Los_Angeles', o.created_at) AS order_created_timestamp_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', o.created_at)) AS order_created_date_pst,
  DATE(CONVERT_TIMEZONE('America/Los_Angeles', o.created_at)) AS sold_date,
  o.financial_status,
  o.fulfillment_status,
  o.total_line_items_price,
  o.cart_token,
  o.token,
  o.checkout_token,
  o.checkout_id as checkout_id_shopify,
  SUM(line.quantity - line.fulfillable_quantity) over (
    PARTITION BY
      line.order_id_shopify
  ) quantity_sold,
  SUM(line.quantity) over (
    PARTITION BY
      line.order_id_shopify
  ) quantity_booked
FROM
  staging.shopify_orders o
  LEFT OUTER JOIN staging.shopify_order_line line ON line.order_id_shopify = o.order_id_shopify and o.store = line.store
  LEFT OUTER JOIN staging.shopify_order_shipping_line ship ON ship.order_id_shopify = o.order_id_shopify and o.store = ship.store