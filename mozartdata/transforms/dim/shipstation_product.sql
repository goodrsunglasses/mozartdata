SELECT
  s.item_id_shipstation
, s.sku
, s.display_name
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
, s.no_customs
, s.price
, s.tags
, s.warehouse_location
, s.weight_oz
, s.width
, s.created_order
, s.primary_item_id_flag
, s.multiple_id_flag
FROM
  staging.shipstation_product s