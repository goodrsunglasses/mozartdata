-- CREATE OR REPLACE TABLE fact.shopify_refund_order_line
-- 	COPY GRANTS AS
SELECT order_id                   as order_id_shopify,
       ORDER_ID_EDW,
       source,
       refund_created_date,
       refund_id,
       array_agg(adjustment_reason) adjustment_reason_array,--SADLY THIS HAS TO BE AN ARRAY BECAUSE WE HAVE MULTIPLE ADJUSTMENTS PER ORDER ¯\_(ツ)_/¯
       array_agg(refund_note) refund_note_array,
       SUM(amount_adjustment)     AS amount_adjustment,
       SUM(amount_adjustment_tax) AS amount_adjustment_tax,
       SUM(amount_adjustment_total)      AS amount_adjustment_total,
       sum(QUANTITY_REFUND_LINE)  as quantity_refund_line,
       sum(REFUND_LINE_SUBTOTAL)  as amount_refund_subtotal,
       sum(REFUND_LINE_TAX)       as amount_refund_tax,
       sum(REFUND_LINE_TOTAL)     as amount_refund_total
FROM fact.shopify_refund_order_item_detail
GROUP BY order_id,
         refund_created_date,
         ORDER_ID_EDW,
         source,
         refund_id,
         refund_note
