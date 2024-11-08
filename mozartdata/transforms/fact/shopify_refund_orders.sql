create or replace table fact.shopify_refund_orders copy grants as
SELECT order_id_shopify,
       ORDER_ID_EDW,
       store,
       array_agg(adjustment_reason) adjustment_reason_array,--SADLY THIS HAS TO BE AN ARRAY BECAUSE WE HAVE MULTIPLE ADJUSTMENTS PER ORDER ¯\_(ツ)_/¯
       array_agg(refund_note) refund_note_array,
       sum(QUANTITY_REFUND_LINE)  as quantity_refund_line,
       avg(amount_adjustment)  as amount_adjustment,
       avg(amount_adjustment_tax) as amount_adjustment_tax,
       avg(amount_adjustment_total) as amount_adjustment_total,
       sum(amount_refund_line_subtotal) as amount_refund_line_subtotal,
       sum(amount_refund_line_tax) as amount_refund_line_tax,
       sum(amount_refund_line_total) as amount_refund_line_total,
       sum(amount_refund_line_subtotal)+avg(amount_adjustment)  as amount_refund_subtotal,
       sum(amount_refund_line_tax)+avg(amount_adjustment_tax)       as amount_refund_tax,
       sum(amount_refund_line_total)+avg(amount_adjustment_total)     as amount_refund_total
FROM fact.shopify_refund_order_item_detail
GROUP BY ALL