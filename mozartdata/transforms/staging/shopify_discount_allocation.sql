/*
Purpose: Create a staging table for discount_allocation to union all the shopify stores.
excludes Goodrwill, no discounts on that store.
One row per discount allocation (order line discount amount) per store?

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )

SELECT
  'Goodr.com' as store
, 'D2C' as category
, concat(da.order_line_id,'_',da.index,'_') as discount_allocation_id_edw
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
, concat(da.order_line_id,'_',da.index,'_') as discount_allocation_id_edw
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
, concat(da.order_line_id,'_',da.index,'_') as discount_allocation_id_edw
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
, concat(da.order_line_id,'_',da.index,'_') as discount_allocation_id_edw
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
UNION ALL
SELECT
  'Cabana' as store
, 'D2C' as category
, concat(da.order_line_id,'_',da.index,'_') as discount_allocation_id_edw
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
  cabana.discount_allocation da

