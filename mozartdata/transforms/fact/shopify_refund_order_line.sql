-- CREATE OR REPLACE TABLE fact.shopify_refund_order_line
-- 	COPY GRANTS AS
SELECT order_id,
	   ORDER_ID_EDW,
	   source,
	   COUNT(refund_id)           AS refund_count,
	   SUM(ADJUSTMENT_AMOUNT)     AS adjustment_amount_sum,
	   SUM(ADJUSTMENT_TAX_AMOUNT) AS ADJUSTMENT_TAX_AMOUNT_sum,
	   SUM(ADJUSTMENT_TOTAL)      AS ADJUSTMENT_TOTAL_sum,
	sum(QUANTITY_REFUND_LINE) as QUANTITY_REFUND_LINE_sum,
	sum(REFUND_LINE_SUBTOTAL) as REFUND_LINE_SUBTOTAL_sum,
	sum(REFUND_LINE_TAX) as REFUND_LINE_TAX_sum,
	sum(REFUND_LINE_TOTAL) as REFUND_LINE_TOTAL_sum
FROM fact.shopify_refund_order_item_detail
GROUP BY order_id,
		 ORDER_ID_EDW,
		 source
