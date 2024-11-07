/*
This table is effectively 1 row per order_id_edw and sku (product_id_edw). However, there are cases where a single sku
in shopify has multiple product_ids in shopify, or multiple order_id_shopify for a single order_id_edw

As of 11/1/2024 there are only 207 instances where this isn't unique:
Most are from 2019, largely due to some oddity where there are multiple order_id_shopify for a single order_id_edw

*/
SELECT
  o.order_id_edw
, o.order_id_shopify
, concat(o.store,'_',o.order_id_edw,'_',line.sku) as order_item_id_edw --primary key
, o.store
, line.product_id_shopify
, line.sku                                                 AS product_id_edw
, line.sku
, line.display_name
, avg(line.price)                                               AS rate
, sum(line.quantity)                                            AS quantity_booked
, sum(line.quantity - line.fulfillable_quantity)                AS quantity_sold
, sum(line.fulfillable_quantity)                                AS quantity_unfulfilled
, sum(case when line.fulfillment_status = 'fulfilled' then line.quantity - line.fulfillable_quantity else 0 end) as quantity_fulfilled
, sum(line.price * line.quantity)                          AS amount_booked
, sum(line.price * (line.quantity - line.fulfillable_quantity)) AS amount_sold
, SUM(coalesce(da.amount_standard_discount,0))                         AS amount_standard_discount
, SUM(coalesce(da.amount_yotpo_discount,0))                            AS amount_yotpo_discount
, SUM(coalesce(da.amount_total_discount,0))                            AS amount_total_discount
FROM
  staging.shopify_orders o
  LEFT OUTER JOIN staging.shopify_order_line line
                  ON line.order_id_shopify = o.order_id_shopify AND line.store = o.store
  LEFT OUTER JOIN fact.shopify_discount_item da
                  ON da.order_line_id_shopify = line.order_line_id_shopify AND da.store = o.store
  LEFT OUTER JOIN dim.product p ON p.product_id_edw = line.sku
GROUP BY ALL

