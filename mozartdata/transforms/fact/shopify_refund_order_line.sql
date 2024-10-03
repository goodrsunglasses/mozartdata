-- CREATE OR REPLACE TABLE fact.shopify_refund_order_line
-- 	COPY GRANTS AS
SELECT order_id                   as order_id_shopify,
       ORDER_ID_EDW,
       source,
       refund_created_date,
       refund_id,
       array_agg(adjustment_reason) adjustment_reason_array,--SADLY THIS HAS TO BE AN ARRAY BECAUSE WE HAVE MULTIPLE ADJUSTMENTS PER ORDER ¯\_(ツ)_/¯
       array_agg(refund_note) refund_note_array,
       SUM(ADJUSTMENT_AMOUNT)     AS adjustment_amount_sum,
       SUM(ADJUSTMENT_TAX_AMOUNT) AS ADJUSTMENT_TAX_AMOUNT_sum,
       SUM(ADJUSTMENT_TOTAL)      AS ADJUSTMENT_TOTAL_sum,
       sum(QUANTITY_REFUND_LINE)  as QUANTITY_REFUND_LINE_sum,
       sum(REFUND_LINE_SUBTOTAL)  as REFUND_LINE_SUBTOTAL_sum,
       sum(REFUND_LINE_TAX)       as REFUND_LINE_TAX_sum,
       sum(REFUND_LINE_TOTAL)     as REFUND_LINE_TOTAL_sum
FROM fact.shopify_refund_order_item_detail
GROUP BY order_id,
         refund_created_date,
         ORDER_ID_EDW,
         source,
         refund_id,
         refund_note
