WITH
  staging AS
    (
      SELECT
        s.active
      , s.createdate                                                AS created_timestamp
      , DATE(s.createdate)                                          AS created_date
      , s.customscountrycode                                        AS customs_country_code
      , s.customsdescription                                        AS customs_description
      , s.customsvalue as customs_value
      , s.defaultcarriercode as default_carrier_code
      , s.defaultconfirmation as default_confirmation
      , s.defaultintlcarriercode as default_international_carrier_code
      , s.defaultintlpackagecode as default_international_package_code
      , s.defaultintlservicecode as default_international_service_code
      , s.defaultpackagecode as default_package_code
      , s.defaultservicecode as default_service_code
      , s.fulfillmentsku as fulfillment_sku
      , s.height as height
      , s.internalnotes as product_description
      , s.length as length
      , s.modifydate as modify_timestamp
     , date(s.modifydate) as modify_date
      , s.name as display_name
      , s.nocustoms as no_customs
      , s.price as price
      , s.productid as item_id_shipstation
      , s.sku
      , s.tags
      , s.warehouselocation as warehouse_location
      , s.weightoz as weight_oz
      , s.width as width
      , RANK() OVER (PARTITION BY s.sku ORDER BY s.createdate DESC) AS created_order
      FROM
        shipstation_portable.shipstation_products_8589936627 s
      )
SELECT
  s.*
, CASE WHEN s.created_order = 1 THEN TRUE ELSE FALSE END                              AS primary_item_id_flag
, CASE WHEN MAX(created_order) OVER (PARTITION BY s.sku) > 1 THEN TRUE ELSE FALSE END AS multiple_id_flag
FROM
  staging s

