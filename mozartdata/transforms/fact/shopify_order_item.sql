/*
This table is effectively 1 row per order_id_edw and sku (product_id_edw). However, there are cases where a single sku
in shopify has multiple product_ids in shopify, or multiple order_id_shopify for a single order_id_edw

As of 11/1/2024 there are only 207 instances where this isn't unique:
Most are from 2019, largely due to some oddity where there are multiple order_id_shopify for a single order_id_edw

*/
with discounts as
  (
    select
      order_line_id_shopify
    , store
    , sku
    , sum(coalesce(amount_standard_discount,0)) as amount_standard_discount
    , sum(coalesce(amount_yotpo_discount,0)) as amount_yotpo_discount
    , sum(coalesce(amount_total_discount,0)) as amount_total_discount
    from
      fact.shopify_discount_item
    group by all
  )
SELECT
  o.order_id_edw
, o.order_id_shopify
, CONCAT(o.store, '_', o.order_id_edw, '_', line.sku)                                                            AS order_item_id_edw --primary key
, o.store
, line.product_id_shopify
, line.sku                                                                                                       AS product_id_edw
, line.sku
, line.display_name
, AVG(line.price)                                                                                                AS rate
, SUM(line.quantity)                                                                                             AS quantity_booked
, SUM(line.quantity - line.fulfillable_quantity)                                                                 AS quantity_sold
, SUM(line.fulfillable_quantity)                                                                                 AS quantity_unfulfilled
, SUM(CASE
        WHEN line.fulfillment_status = 'fulfilled' THEN line.quantity - line.fulfillable_quantity
        ELSE 0 END)                                                                                              AS quantity_fulfilled
, SUM(line.price * line.quantity)                                                                                AS amount_booked
, SUM(line.price * (line.quantity - line.fulfillable_quantity))                                                  AS amount_sold
, SUM(COALESCE(da.amount_standard_discount, 0))                                                                  AS amount_standard_discount
, SUM(line.price * (line.quantity - line.fulfillable_quantity)) -SUM(COALESCE(da.amount_standard_discount, 0))   AS amount_revenue_sold
, SUM(COALESCE(da.amount_yotpo_discount, 0))                                                                     AS amount_yotpo_discount
, SUM(COALESCE(da.amount_total_discount, 0))                                                                     AS amount_total_discount
, SUM(COALESCE(rol.quantity_refund_line, 0))                                                                     AS quantity_refund_line
, SUM(rol.amount_refund_subtotal)                                                                                AS amount_refund_subtotal
, SUM(rol.amount_refund_tax)                                                                                     AS amount_refund_tax
, SUM(rol.amount_refund_total)                                                                                   AS amount_refund_total
FROM
  staging.shopify_orders o
  LEFT OUTER JOIN staging.shopify_order_line line
                  ON line.order_id_shopify = o.order_id_shopify AND line.store = o.store
  LEFT OUTER JOIN discounts da
                  ON da.order_line_id_shopify = line.order_line_id_shopify AND da.store = o.store
  LEFT OUTER JOIN dim.product p ON p.product_id_edw = line.sku
  LEFT OUTER JOIN fact.shopify_refund_order_line rol
                  ON line.order_line_id_shopify = rol.order_line_id_shopify AND o.store = rol.store
GROUP BY ALL

