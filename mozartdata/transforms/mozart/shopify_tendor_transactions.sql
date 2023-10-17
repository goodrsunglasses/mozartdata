SELECT *
FROM shopify.tender_transaction
WHERE DATE_TRUNC('MONTH', processed_at) >= DATEADD(MONTH, -1, CURRENT_DATE())
  AND DATE_TRUNC('MONTH', processed_at) <= CURRENT_DATE();