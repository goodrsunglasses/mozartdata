--This table may seem incredibly perfunctory, but we've been burned in the past by assuming "We won't need SPECIFICALLY shopify refund item level information"
--So it exists to just play it safe, and keep us Scaleagile. We are SPECIFICALLY avoiding Adjustment info here, because it does not tie to a specific item on the order
-- CREATE OR REPLACE TABLE fact.shopify_refund_order_line
-- 	COPY GRANTS AS
SELECT
    refund_id,
    order_id_edw,
    store,
    sku,
    display_name,
    quantity_refund_line,
    sum(amount_refund_line_subtotal) as amount_refund_line_subtotal,
    sum(amount_refund_line_tax) as amount_refund_line_tax,
    sum(amount_refund_line_total) as amount_refund_line_total
FROM fact.shopify_refund_order_item_detail
GROUP BY ALL
