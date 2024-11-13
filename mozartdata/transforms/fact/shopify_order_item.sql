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
, case when line.sku not like 'GC%' then round((line.price * (line.quantity - line.fulfillable_quantity)) - SUM(coalesce(da.amount_total_discount,0)), 2) else 0 end as amount_sales --similar to revenue
, case when line.sku like 'GC%' then sum(line.price * (line.quantity - line.fulfillable_quantity)) else 0 end AS amount_gift_card
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
