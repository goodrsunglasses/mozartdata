SELECT
  'Goodr.com' AS store
, order_id as order_id_shopify
, id as order_line_id_shopify
, product_id as product_id_shopify
, variant_id
, name as display_name
, title
, vendor
, price
, price_set
, quantity
, grams
, sku
, fulfillable_quantity
, gift_card
, requires_shipping
, taxable
, variant_title
, properties
, index
, total_discount
, total_discount_set
, pre_tax_price
, pre_tax_price_set
, product_exists
, fulfillment_status
, variant_inventory_management
, tax_code
, _fivetran_synced
FROM
  shopify.order_line
UNION ALL
SELECT
  'Specialty' AS store
, order_id as order_id_shopify
, id as order_line_id_shopify
, product_id as product_id_shopify
, variant_id
, name as display_name
, title
, vendor
, price
, price_set
, quantity
, grams
, sku
, fulfillable_quantity
, gift_card
, requires_shipping
, taxable
, variant_title
, properties
, index
, total_discount
, total_discount_set
, pre_tax_price
, pre_tax_price_set
, product_exists
, fulfillment_status
, variant_inventory_management
, tax_code
, _fivetran_synced
FROM
  specialty_shopify.order_line
UNION ALL
SELECT
  'Goodr.ca' AS store
, order_id as order_id_shopify
, id as order_line_id_shopify
, product_id as product_id_shopify
, variant_id
, name as display_name
, title
, vendor
, price
, price_set
, quantity
, grams
, sku
, fulfillable_quantity
, gift_card
, requires_shipping
, taxable
, variant_title
, properties
, index
, total_discount
, total_discount_set
, pre_tax_price
, pre_tax_price_set
, product_exists
, fulfillment_status
, variant_inventory_management
, tax_code
, _fivetran_synced
FROM
  goodr_canada_shopify.order_line
UNION ALL
SELECT
  'Specialty CAN' AS store
, order_id as order_id_shopify
, id as order_line_id_shopify
, product_id as product_id_shopify
, variant_id
, name as display_name
, title
, vendor
, price
, price_set
, quantity
, grams
, sku
, fulfillable_quantity
, gift_card
, requires_shipping
, taxable
, variant_title
, properties
, index
, total_discount
, total_discount_set
, pre_tax_price
, pre_tax_price_set
, product_exists
, fulfillment_status
, variant_inventory_management
, tax_code
, _fivetran_synced
FROM
  sellgoodr_canada_shopify.order_line
UNION ALL
SELECT
  'Goodrwill' AS store
, order_id as order_id_shopify
, id as order_line_id_shopify
, product_id as product_id_shopify
, variant_id
, name as display_name
, title
, vendor
, price
, price_set
, quantity
, grams
, sku
, fulfillable_quantity
, gift_card
, requires_shipping
, taxable
, variant_title
, properties
, index
, total_discount
, total_discount_set
, pre_tax_price
, pre_tax_price_set
, product_exists
, fulfillment_status
, variant_inventory_management
, tax_code
, _fivetran_synced
FROM
  goodrwill_shopify.order_line
UNION ALL
SELECT
  'Cabana' AS store
, order_id as order_id_shopify
, id as order_line_id_shopify
, product_id as product_id_shopify
, variant_id
, name as display_name
, title
, vendor
, price
, price_set
, quantity
, grams
, sku
, fulfillable_quantity
, gift_card
, requires_shipping
, taxable
, variant_title
, properties
, index
, total_discount
, total_discount_set
, pre_tax_price
, pre_tax_price_set
, product_exists
, fulfillment_status
, variant_inventory_management
, tax_code
, _fivetran_synced
FROM
  cabana.order_line