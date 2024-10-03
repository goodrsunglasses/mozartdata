--This table may seem incredibly perfunctory, but we've been burned in the past by assuming "We won't need SPECIFICALLY shopify refund item level information"
--So it exists to just play it safe, and keep us Scaleagile
-- CREATE OR REPLACE TABLE fact.shopify_refund_order_line
-- 	COPY GRANTS AS
SELECT
    refund_id,
    order_id_edw,
    source,
    sku,
    display_name,
    refund_line_id,
    order_line_id,
    quantity_refund_line,
    refund_line_subtotal,
    refund_line_tax,
    refund_line_total
FROM fact.shopify_refund_order_item_detail
