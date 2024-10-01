/*
Create a staging table for discount_code to union all the shopify stores.
excluding Goodrwill. That store doesn't have the other discount tables- discount allocation and discount_application
*/

SELECT
  'Goodr.com' AS store
, 'D2C'       AS category
, dc.id as discount_code_id_shopify
, dc.price_rule_id
, dc.code as discount_code
, dc.created_at as created_timestamp
, date(dc.created_at) as created_date
, dc.updated_at as updated_timestamp
, date(dc.updated_at) as updated_date
, dc.usage_count
, dc._fivetran_synced
FROM
  shopify.discount_code dc
UNION ALL
SELECT
  'Specialty' as store
, 'B2B' as category
, dc.id as discount_code_id_shopify
, dc.price_rule_id
, dc.code as discount_code
, dc.created_at as created_timestamp
, date(dc.created_at) as created_date
, dc.updated_at as updated_timestamp
, date(dc.updated_at) as updated_date
, dc.usage_count
, dc._fivetran_synced
FROM
  specialty_shopify.discount_code dc
UNION ALL
SELECT
  'Goodr.ca' as store
, 'D2C' as category
, dc.id as discount_code_id_shopify
, dc.price_rule_id
, dc.code as discount_code
, dc.created_at as created_timestamp
, date(dc.created_at) as created_date
, dc.updated_at as updated_timestamp
, date(dc.updated_at) as updated_date
, dc.usage_count
, dc._fivetran_synced
FROM
  goodr_canada_shopify.discount_code dc
UNION ALL
SELECT
  'Specialty CAN' as store
, 'B2B' as category
, dc.id as discount_code_id_shopify
, dc.price_rule_id
, dc.code as discount_code
, dc.created_at as created_timestamp
, date(dc.created_at) as created_date
, dc.updated_at as updated_timestamp
, date(dc.updated_at) as updated_date
, dc.usage_count
, dc._fivetran_synced
FROM
  sellgoodr_canada_shopify.discount_code dc
UNION ALL
SELECT
  'Cabana' as store
, 'D2C' as category
, dc.id as discount_code_id_shopify
, dc.price_rule_id
, dc.code as discount_code
, dc.created_at as created_timestamp
, date(dc.created_at) as created_date
, dc.updated_at as updated_timestamp
, date(dc.updated_at) as updated_date
, dc.usage_count
, dc._fivetran_synced
FROM
  cabana.discount_code dc

