/*
This table is effectively 1 row per order_id_edw and sku (product_id_edw). However, there are cases where a single sku
in shopify has multiple product_ids in shopify, or multiple order_id_shopify for a single order_id_edw
As of 11/1/2024 there are only 207 instances where this isn't unique:
Most are from 2019, largely due to some oddity where there are multiple order_id_shopify for a single order_id_edw

*/
WITH
  discounts       AS
    (
      SELECT
        order_line_id_shopify
      , store
      , sku
      , SUM(COALESCE(amount_standard_discount, 0)) AS amount_standard_discount
      , SUM(COALESCE(amount_yotpo_discount, 0))    AS amount_yotpo_discount
      , SUM(COALESCE(amount_total_discount, 0))    AS amount_total_discount
      FROM
        fact.shopify_discount_item
      GROUP BY ALL
      )
SELECT
  o.order_id_edw
, o.order_id_shopify
, CONCAT(o.store, '_', o.order_id_edw, '_', line.sku)                                                         AS order_item_id_edw --primary key
, o.store
, line.product_id_shopify
, line.sku AS product_id_edw
, line.sku
, line.display_name
, AVG(line.price) AS rate
, SUM(line.quantity) AS quantity_booked
, SUM(line.quantity - line.fulfillable_quantity) AS quantity_sold
, SUM(line.fulfillable_quantity) AS quantity_unfulfilled
, SUM(CASE  WHEN line.fulfillment_status = 'fulfilled' THEN line.quantity - line.fulfillable_quantity ELSE 0 END) AS quantity_fulfilled
, SUM(line.price * line.quantity) AS amount_product_booked
, CASE
    WHEN line.sku NOT LIKE 'GC%' THEN ROUND(SUM(line.price * line.quantity) - SUM(COALESCE(da.amount_standard_discount, 0)), 2)
    ELSE 0 END                                                                                                AS amount_sales_booked
, SUM(line.price * (line.quantity - line.fulfillable_quantity)) AS                                               amount_product_sold
, SUM(COALESCE(da.amount_standard_discount, 0))                                                               AS amount_standard_discount
, CASE
    WHEN line.sku NOT LIKE 'GC%' THEN ROUND(SUM(line.price * (line.quantity - line.fulfillable_quantity)) - SUM(COALESCE(da.amount_standard_discount, 0)), 2)
    ELSE 0 END                                                                                                AS amount_sales --similar to revenue
, CASE
    WHEN line.sku LIKE 'GC%' THEN SUM(line.price * (line.quantity - line.fulfillable_quantity))
    ELSE 0 END                                                                                                AS amount_gift_card_sold
, ROUND(SUM(line.price * (line.quantity - line.fulfillable_quantity)) - SUM(COALESCE(da.amount_total_discount, 0)), 2) AS amount_paid
, SUM(COALESCE(da.amount_yotpo_discount, 0))                                                                  AS amount_yotpo_discount
, SUM(COALESCE(da.amount_total_discount, 0))                                                                  AS amount_total_discount
, SUM(COALESCE(rol.quantity_refunded, 0))                                                                  AS quantity_refunded
, SUM(COALESCE(rol.amount_refund_line_subtotal, 0))                                                                AS amount_refund_product
, SUM(COALESCE(rol.amount_refund_line_tax, 0))                                                                     AS amount_refund_tax
, SUM(COALESCE(rol.amount_refund_line_total, 0))                                                                   AS amount_refund_total

FROM
  staging.shopify_orders o
  LEFT OUTER JOIN staging.shopify_order_line line
    ON line.order_id_shopify = o.order_id_shopify AND line.store = o.store
  LEFT OUTER JOIN discounts da
    ON da.order_line_id_shopify = line.order_line_id_shopify AND da.store = o.store
  LEFT OUTER JOIN dim.product p ON p.product_id_edw = line.sku
  LEFT OUTER JOIN fact.shopify_refund_order_item rol
    ON line.order_id_shopify = rol.order_id_shopify AND line.sku = rol.sku AND o.store = rol.store
GROUP BY ALL