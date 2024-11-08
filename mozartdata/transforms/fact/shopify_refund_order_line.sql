/*
This table is at the refund, order and line level. This will split skus into multiple rows.
This also includes adjustments as well as line item refunds.
*/
SELECT order_id_shopify,
       ORDER_ID_EDW,
       store,
       refund_created_date,
       refund_id_shopify,
       refund_line_id_shopify,
       order_line_id_shopify,
       array_agg(adjustment_reason) adjustment_reason_array,--SADLY THIS HAS TO BE AN ARRAY BECAUSE WE HAVE MULTIPLE ADJUSTMENTS PER ORDER ¯\_(ツ)_/¯
       array_agg(refund_note) refund_note_array,
       sum(QUANTITY_REFUND_LINE)  as quantity_refund_line,
       sum(amount_refund_line_subtotal)  as amount_refund_subtotal,
       sum(amount_refund_line_tax)       as amount_refund_tax,
       sum(amount_refund_line_total)     as amount_refund_total
FROM fact.shopify_refund_order_item_detail
GROUP BY ALL
