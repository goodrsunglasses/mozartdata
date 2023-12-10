SELECT
  id,
  name,
  financial_status,
  fulfillment_status
FROM
  shopify."ORDER"
union all 
SELECT
  id,
  name,
  financial_status,
  fulfillment_status
FROM
  specialty_shopify."ORDER"