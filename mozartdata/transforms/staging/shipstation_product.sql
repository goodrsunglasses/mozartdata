/*
Purpose: show each item and its metadata in Shipstation. One row per item id.

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
  , staging as
    (
      SELECT
        s.active
      , s.createdate                                                AS created_timestamp
      , DATE(s.createdate)                                          AS created_date
      , s.customscountrycode                                        AS customs_country_code
      , s.customsdescription                                        AS customs_description
      , s.customsvalue                                              AS customs_value
      , s.defaultcarriercode                                        AS default_carrier_code
      , s.defaultconfirmation                                       AS default_confirmation
      , s.defaultintlcarriercode                                    AS default_international_carrier_code
      , s.defaultintlpackagecode                                    AS default_international_package_code
      , s.defaultintlservicecode                                    AS default_international_service_code
      , s.defaultpackagecode                                        AS default_package_code
      , s.defaultservicecode                                        AS default_service_code
      , s.fulfillmentsku                                            AS fulfillment_sku
      , s.height                                                    AS height
      , s.internalnotes                                             AS product_description
      , s.length                                                    AS length
      , s.modifydate                                                AS modify_timestamp
      , DATE(s.modifydate)                                          AS modify_date
      , s.name                                                      AS display_name
      , s.nocustoms                                                 AS no_customs
      , s.price                                                     AS price
      , s.productid                                                 AS item_id_shipstation
      , s.sku
      , s.tags
      , s.warehouselocation                                         AS warehouse_location
      , s.weightoz                                                  AS weight_oz
      , s.width                                                     AS width
      , RANK() OVER (PARTITION BY s.sku ORDER BY s.createdate DESC) AS created_order
      FROM
        shipstation_portable.shipstation_products_8589936627 s
      )
SELECT
  s.item_id_shipstation
, s.active
, s.created_timestamp
, s.created_date
, s.customs_country_code
, s.customs_description
, s.customs_value
, s.default_carrier_code
, s.default_confirmation
, s.default_international_carrier_code
, s.default_international_package_code
, s.default_international_service_code
, s.default_package_code
, s.default_service_code
, s.fulfillment_sku
, s.height
, s.product_description
, s.length
, s.modify_timestamp
, s.modify_date
, s.display_name
, s.no_customs
, s.price
, s.sku
, s.tags
, s.warehouse_location
, s.weight_oz
, s.width
, s.created_order
, CASE WHEN s.created_order = 1 THEN TRUE ELSE FALSE END                              AS primary_item_id_flag
, CASE WHEN MAX(created_order) OVER (PARTITION BY s.sku) > 1 THEN TRUE ELSE FALSE END AS multiple_id_flag
FROM
  staging s

