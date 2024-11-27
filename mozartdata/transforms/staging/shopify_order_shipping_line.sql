/*
Purpose: to show the shipping information for each order in Shopify.
One row per shipment (id) per order per store.

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
, order_id as order_id_shopify
, id
, code
, price
, source
, title
, carrier_identifier
, requested_fulfillment_service_id
, phone
, delivery_category
, discounted_price
, discounted_price_set
, price_set
, _fivetran_synced
, is_removed
FROM
  shopify.order_shipping_line
UNION ALL
SELECT
  'Specialty' AS store
, order_id as order_id_shopify
, id
, code
, price
, source
, title
, carrier_identifier
, requested_fulfillment_service_id
, phone
, delivery_category
, discounted_price
, discounted_price_set
, price_set
, _fivetran_synced
, is_removed
FROM
  specialty_shopify.order_shipping_line
UNION ALL
SELECT
  'Goodr.ca' AS store
, order_id as order_id_shopify
, id
, code
, price
, source
, title
, carrier_identifier
, requested_fulfillment_service_id
, phone
, delivery_category
, discounted_price
, discounted_price_set
, price_set
, _fivetran_synced
, is_removed
FROM
  goodr_canada_shopify.order_shipping_line
UNION ALL
SELECT
  'Specialty CAN' AS store
, order_id as order_id_shopify
, id
, code
, price
, source
, title
, carrier_identifier
, requested_fulfillment_service_id
, phone
, delivery_category
, discounted_price
, discounted_price_set
, price_set
, _fivetran_synced
, is_removed
FROM
  sellgoodr_canada_shopify.order_shipping_line
UNION ALL
SELECT
  'Goodrwill' AS store
, order_id as order_id_shopify
, id
, code
, price
, source
, title
, carrier_identifier
, requested_fulfillment_service_id
, phone
, delivery_category
, discounted_price
, discounted_price_set
, price_set
, _fivetran_synced
, is_removed
FROM
  goodrwill_shopify.order_shipping_line
UNION ALL
SELECT
  'Cabana' AS store
, order_id as order_id_shopify
, id
, code
, price
, source
, title
, carrier_identifier
, requested_fulfillment_service_id
, phone
, null as delivery_category
, discounted_price
, discounted_price_set
, price_set
, _fivetran_synced
, is_removed
FROM
  cabana.order_shipping_line