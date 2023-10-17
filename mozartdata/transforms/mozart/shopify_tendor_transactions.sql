SELECT tt.*, ot.name
FROM shopify.tender_transaction tt
JOIN shopify."ORDER" ot ON tt.order_id = ot.id
WHERE DATE_TRUNC('MONTH', tt.processed_at) >= DATEADD(MONTH, -1, CURRENT_DATE())
  AND DATE_TRUNC('MONTH', tt.processed_at) <= CURRENT_DATE();