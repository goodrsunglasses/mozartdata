/*
Purpose: Create a staging table for discount_application to union all the shopify stores.
excludes Goodrwill, no discounts on that store.
One row per discount application (order amount discount) per store?

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
  'Goodr.com' AS store
, 'D2C'       AS category
, concat(da.order_id,'_',da.index) as discount_application_id_edw
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
, concat(da.order_id,'_',da.index) as discount_application_id_edw
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
, concat(da.order_id,'_',da.index) as discount_application_id_edw
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
, concat(da.order_id,'_',da.index) as discount_application_id_edw
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
UNION ALL
SELECT
  'Cabana' AS store
, 'D2C'           AS category
, concat(da.order_id,'_',da.index) as discount_application_id_edw
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
  cabana.discount_application da

