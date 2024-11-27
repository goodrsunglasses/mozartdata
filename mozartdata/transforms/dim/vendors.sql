/*
Purpose: Show vendors associated with our purchase orders. One row per vendor in Netsuite.

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
  id as vendor_id_edw,
  id as vendor_id_ns,
  entityid as name,
  balance,
  companyname as company_name,
  currency as currency_id_ns,
  defaultbillingaddress as billing_address_id_ns,
  defaultshippingaddress as shipping_address_id_ns,
  email,
  globalsubscriptionstatus as global_subscription_status_id_ns
FROM
  netsuite.vendor