/*
Create a staging table for discount_application to union all the shopify stores.
excludes Goodrwill, no discounts on that store.
*/

SELECT
  'Goodr.com' AS store
, 'D2C'       AS category
, da.order_id as order_id_shopify
, da.index
, da.type
, da.title
, da.code as discount_code
, da.description
, da.value
, da.value_type
, da.allocation_method
, da.target_selection
, da.target_type
, da._fivetran_synced
FROM
  shopify.discount_application da
UNION ALL
SELECT
  'Specialty' AS store
, 'B2B'       AS category
, da.order_id as order_id_shopify
, da.index
, da.type
, da.title
, da.code as discount_code
, da.description
, da.value
, da.value_type
, da.allocation_method
, da.target_selection
, da.target_type
, da._fivetran_synced
FROM
  specialty_shopify.discount_application da
UNION ALL
SELECT
  'Goodr.ca' AS store
, 'D2C'      AS category
, da.order_id as order_id_shopify
, da.index
, da.type
, da.title
, da.code as discount_code
, da.description
, da.value
, da.value_type
, da.allocation_method
, da.target_selection
, da.target_type
, da._fivetran_synced
FROM
  goodr_canada_shopify.discount_application da
UNION ALL
SELECT
  'Specialty CAN' AS store
, 'B2B'           AS category
, da.order_id as order_id_shopify
, da.index
, da.type
, da.title
, da.code as discount_code
, da.description
, da.value
, da.value_type
, da.allocation_method
, da.target_selection
, da.target_type
, da._fivetran_synced
FROM
  sellgoodr_canada_shopify.discount_application da

