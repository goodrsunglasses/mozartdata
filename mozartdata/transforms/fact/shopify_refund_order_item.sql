/*
This table may seem incredibly perfunctory, but we've been burned in the past by assuming "We won't need SPECIFICALLY shopify refund item level information"
So it exists to just play it safe, and keep us Scaleagile. We are SPECIFICALLY avoiding Adjustment info here, because it does not tie to a specific item on the order
We are having to pull display name from dim.product because in some cases a sku can have multiple display names in shopify.
This table is 1 row per store, refund, order and sku combination. A single order can have multiple refunds.
*/
SELECT
    concat(roid.store,'_',roid.refund_id_shopify,'_',roid.order_id_edw,'_',roid.sku) refund_order_item_id_edw, --primary_key
    roid.refund_id_shopify,
    roid.order_id_edw,
    roid.order_id_shopify,
    roid.store,
    roid.sku,
    p.display_name,
    sum(roid.quantity_refund_line) as quantity_refunded,
    sum(roid.amount_refund_line_subtotal) as amount_refund_line_subtotal,
    sum(roid.amount_refund_line_tax) as amount_refund_line_tax,
    sum(roid.amount_refund_line_total) as amount_refund_line_total
FROM fact.shopify_refund_order_item_detail roid
LEFT JOIN
  dim.product p
  ON p.sku = roid.sku
GROUP BY ALL
