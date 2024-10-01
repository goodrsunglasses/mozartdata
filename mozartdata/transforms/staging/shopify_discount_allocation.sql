/*
Create a staging table for discount_allocation to union all the shopify stores
*/

SELECT
  'Goodr.com' as store
, 'D2C' as category
, da.order_line_id
, da.index
, da.discount_application_index
, da.amount
, da.amount_set_shop_money_amount
, da.amount_set_shop_money_currency_code
, da.amount_set_presentment_money_amount
, da.amount_set_presentment_money_currency_code
, da._fivetran_synced
FROM
  shopify.discount_allocation da
UNION ALL
SELECT
  'Specialty' as store
, 'B2B' as category
, da.order_line_id
, da.index
, da.discount_application_index
, da.amount
, da.amount_set_shop_money_amount
, da.amount_set_shop_money_currency_code
, da.amount_set_presentment_money_amount
, da.amount_set_presentment_money_currency_code
, da._fivetran_synced
FROM
  SPECIALTY_SHOPIFY.discount_allocation da
UNION ALL
SELECT
  'Goodr.ca' as store
, 'D2C' as category
, da.order_line_id
, da.index
, da.discount_application_index
, da.amount
, da.amount_set_shop_money_amount
, da.amount_set_shop_money_currency_code
, da.amount_set_presentment_money_amount
, da.amount_set_presentment_money_currency_code
, da._fivetran_synced
FROM
  GOODR_CANADA_SHOPIFY.discount_allocation da
UNION ALL
SELECT
  'Specialty CAN' as store
, 'B2B' as category
, da.order_line_id
, da.index
, da.discount_application_index
, da.amount
, da.amount_set_shop_money_amount
, da.amount_set_shop_money_currency_code
, da.amount_set_presentment_money_amount
, da.amount_set_presentment_money_currency_code
, da._fivetran_synced
FROM
  SELLGOODR_CANADA_SHOPIFY.discount_allocation da

