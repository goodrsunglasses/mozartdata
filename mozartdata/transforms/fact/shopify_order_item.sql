SELECT
  o.order_id_edw
, o.order_id_shopify
, o.store
, line.order_line_id_shopify
, line.product_id_shopify
, line.sku                                                 AS product_id_edw
, line.sku
, line.display_name
, line.price                                               AS rate
, line.quantity                                            AS quantity_booked
, line.quantity - line.fulfillable_quantity                AS quantity_sold
, line.fulfillable_quantity                                AS quantity_unfulfilled
, line.price * line.quantity                               AS amount_booked
, line.price * (line.quantity - line.fulfillable_quantity) AS amount_sold
, SUM(coalesce(da.amount_standard_discount,0))                         AS amount_standard_discount
, SUM(coalesce(da.amount_yotpo_discount,0))                            AS amount_yotpo_discount
, SUM(coalesce(da.amount_total_discount,0))                            AS amount_total_discount
, line.fulfillment_status
FROM
  staging.shopify_orders o
  LEFT OUTER JOIN staging.shopify_order_line line
                  ON line.order_id_shopify = o.order_id_shopify AND line.store = o.store
  LEFT OUTER JOIN fact.shopify_discount_item da
                  ON da.order_line_id_shopify = line.order_line_id_shopify AND da.store = o.store
  LEFT OUTER JOIN dim.product p ON p.product_id_edw = line.sku
GROUP BY ALL
