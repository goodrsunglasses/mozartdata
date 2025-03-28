/*
Purpose: to show each order in Shopify
One row per order id

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
  'Goodr.com'                                                        AS store
, o.id as order_id_shopify
, o.name as order_id_edw
, o.note
, o.email
, o.taxes_included
, o.currency
, o.subtotal_price
, o.subtotal_price_set
, o.total_tax as amount_tax_sold
, o.total_tax_set
, o.total_price as amount_sold
, o.total_price_set
, o.created_at
, o.updated_at
, o.shipping_address_name
, o.shipping_address_first_name
, o.shipping_address_last_name
, o.shipping_address_company
, o.shipping_address_phone
, o.shipping_address_address_1
, o.shipping_address_address_2
, o.shipping_address_city
, o.shipping_address_country
, o.shipping_address_country_code
, o.shipping_address_province
, o.shipping_address_province_code
, o.shipping_address_zip
, o.shipping_address_latitude
, o.shipping_address_longitude
, o.billing_address_name
, o.billing_address_first_name
, o.billing_address_last_name
, o.billing_address_company
, o.billing_address_phone
, o.billing_address_address_1
, o.billing_address_address_2
, o.billing_address_city
, o.billing_address_country
, o.billing_address_country_code
, o.billing_address_province
, o.billing_address_province_code
, o.billing_address_zip
, o.billing_address_latitude
, o.billing_address_longitude
, o.customer_id
, o.location_id
, o.user_id
, o.app_id
, o.number
, o.order_number
, o.financial_status
, o.fulfillment_status
, o.processed_at
, o.referring_site
, o.cancel_reason
, o.cancelled_at
, o.closed_at
, o.total_discounts as amount_discount
, o.total_tip_received
, o.current_total_price
, o.current_total_discounts
, o.current_subtotal_price
, o.current_total_tax
, o.current_total_discounts_set
, o.current_total_duties_set
, o.current_total_price_set
, o.current_subtotal_price_set
, o.current_total_tax_set
, o.total_discounts_set
, o.total_shipping_price_set
, o.total_line_items_price
, o.total_line_items_price_set
, o.original_total_duties_set
, o.total_weight
, o.source_name
, o.browser_ip
, o.buyer_accepts_marketing
, o.confirmed
, o.token
, o.cart_token
, o.checkout_token
, o.checkout_id
, o.customer_locale
, o.device_id
, o.landing_site_ref
, o.presentment_currency
, o.reference
, o.source_identifier
, o.source_url
, o._fivetran_deleted
, o.order_status_url
, o.test
, o.payment_gateway_names
, o.note_attributes
, o.client_details_user_agent
, o.landing_site_base_url
, o._fivetran_synced
, o.company_id
, o.company_location_id
FROM
  shopify."ORDER" o
UNION ALL
SELECT
  'Specialty'                                                        AS store
, o.id as order_id_shopify
, o.name as order_id_edw
, o.note
, o.email
, o.taxes_included
, o.currency
, o.subtotal_price
, o.subtotal_price_set
, o.total_tax as amount_tax_sold
, o.total_tax_set
, o.total_price as amount_sold
, o.total_price_set
, o.created_at
, o.updated_at
, o.shipping_address_name
, o.shipping_address_first_name
, o.shipping_address_last_name
, o.shipping_address_company
, o.shipping_address_phone
, o.shipping_address_address_1
, o.shipping_address_address_2
, o.shipping_address_city
, o.shipping_address_country
, o.shipping_address_country_code
, o.shipping_address_province
, o.shipping_address_province_code
, o.shipping_address_zip
, o.shipping_address_latitude
, o.shipping_address_longitude
, o.billing_address_name
, o.billing_address_first_name
, o.billing_address_last_name
, o.billing_address_company
, o.billing_address_phone
, o.billing_address_address_1
, o.billing_address_address_2
, o.billing_address_city
, o.billing_address_country
, o.billing_address_country_code
, o.billing_address_province
, o.billing_address_province_code
, o.billing_address_zip
, o.billing_address_latitude
, o.billing_address_longitude
, o.customer_id
, o.location_id
, o.user_id
, o.app_id
, o.number
, o.order_number
, o.financial_status
, o.fulfillment_status
, o.processed_at
, o.referring_site
, o.cancel_reason
, o.cancelled_at
, o.closed_at
, o.total_discounts as amount_discount
, o.total_tip_received
, o.current_total_price
, o.current_total_discounts
, o.current_subtotal_price
, o.current_total_tax
, o.current_total_discounts_set
, o.current_total_duties_set
, o.current_total_price_set
, o.current_subtotal_price_set
, o.current_total_tax_set
, o.total_discounts_set
, o.total_shipping_price_set
, o.total_line_items_price
, o.total_line_items_price_set
, o.original_total_duties_set
, o.total_weight
, o.source_name
, o.browser_ip
, o.buyer_accepts_marketing
, o.confirmed
, o.token
, o.cart_token
, o.checkout_token
, o.checkout_id
, o.customer_locale
, o.device_id
, o.landing_site_ref
, o.presentment_currency
, o.reference
, o.source_identifier
, o.source_url
, o._fivetran_deleted
, o.order_status_url
, o.test
, o.payment_gateway_names
, o.note_attributes
, o.client_details_user_agent
, o.landing_site_base_url
, o._fivetran_synced
, o.company_id
, o.company_location_id
FROM
  specialty_shopify."ORDER" o
UNION ALL
SELECT
  'Goodr.ca'                                                        AS store
, o.id as order_id_shopify
, o.name as order_id_edw
, o.note
, o.email
, o.taxes_included
, o.currency
, o.subtotal_price
, o.subtotal_price_set
, o.total_tax as amount_tax_sold
, o.total_tax_set
, o.total_price as amount_sold
, o.total_price_set
, o.created_at
, o.updated_at
, o.shipping_address_name
, o.shipping_address_first_name
, o.shipping_address_last_name
, o.shipping_address_company
, o.shipping_address_phone
, o.shipping_address_address_1
, o.shipping_address_address_2
, o.shipping_address_city
, o.shipping_address_country
, o.shipping_address_country_code
, o.shipping_address_province
, o.shipping_address_province_code
, o.shipping_address_zip
, o.shipping_address_latitude
, o.shipping_address_longitude
, o.billing_address_name
, o.billing_address_first_name
, o.billing_address_last_name
, o.billing_address_company
, o.billing_address_phone
, o.billing_address_address_1
, o.billing_address_address_2
, o.billing_address_city
, o.billing_address_country
, o.billing_address_country_code
, o.billing_address_province
, o.billing_address_province_code
, o.billing_address_zip
, o.billing_address_latitude
, o.billing_address_longitude
, o.customer_id
, o.location_id
, o.user_id
, o.app_id
, o.number
, o.order_number
, o.financial_status
, o.fulfillment_status
, o.processed_at
, o.referring_site
, o.cancel_reason
, o.cancelled_at
, o.closed_at
, o.total_discounts as amount_discount
, o.total_tip_received
, o.current_total_price
, o.current_total_discounts
, o.current_subtotal_price
, o.current_total_tax
, o.current_total_discounts_set
, o.current_total_duties_set
, o.current_total_price_set
, o.current_subtotal_price_set
, o.current_total_tax_set
, o.total_discounts_set
, o.total_shipping_price_set
, o.total_line_items_price
, o.total_line_items_price_set
, o.original_total_duties_set
, o.total_weight
, o.source_name
, o.browser_ip
, o.buyer_accepts_marketing
, o.confirmed
, o.token
, o.cart_token
, o.checkout_token
, o.checkout_id
, o.customer_locale
, o.device_id
, o.landing_site_ref
, o.presentment_currency
, o.reference
, o.source_identifier
, o.source_url
, o._fivetran_deleted
, o.order_status_url
, o.test
, o.payment_gateway_names
, o.note_attributes
, o.client_details_user_agent
, o.landing_site_base_url
, o._fivetran_synced
, o.company_id
, o.company_location_id
FROM
  goodr_canada_shopify."ORDER" o
UNION ALL
SELECT
  'Specialty CAN'                                                        AS store
, o.id as order_id_shopify
, o.name as order_id_edw
, o.note
, o.email
, o.taxes_included
, o.currency
, o.subtotal_price
, o.subtotal_price_set
, o.total_tax as amount_tax_sold
, o.total_tax_set
, o.total_price as amount_sold
, o.total_price_set
, o.created_at
, o.updated_at
, o.shipping_address_name
, o.shipping_address_first_name
, o.shipping_address_last_name
, o.shipping_address_company
, o.shipping_address_phone
, o.shipping_address_address_1
, o.shipping_address_address_2
, o.shipping_address_city
, o.shipping_address_country
, o.shipping_address_country_code
, o.shipping_address_province
, o.shipping_address_province_code
, o.shipping_address_zip
, o.shipping_address_latitude
, o.shipping_address_longitude
, o.billing_address_name
, o.billing_address_first_name
, o.billing_address_last_name
, o.billing_address_company
, o.billing_address_phone
, o.billing_address_address_1
, o.billing_address_address_2
, o.billing_address_city
, o.billing_address_country
, o.billing_address_country_code
, o.billing_address_province
, o.billing_address_province_code
, o.billing_address_zip
, o.billing_address_latitude
, o.billing_address_longitude
, o.customer_id
, o.location_id
, o.user_id
, o.app_id
, o.number
, o.order_number
, o.financial_status
, o.fulfillment_status
, o.processed_at
, o.referring_site
, o.cancel_reason
, o.cancelled_at
, o.closed_at
, o.total_discounts as amount_discount
, o.total_tip_received
, o.current_total_price
, o.current_total_discounts
, o.current_subtotal_price
, o.current_total_tax
, o.current_total_discounts_set
, o.current_total_duties_set
, o.current_total_price_set
, o.current_subtotal_price_set
, o.current_total_tax_set
, o.total_discounts_set
, o.total_shipping_price_set
, o.total_line_items_price
, o.total_line_items_price_set
, o.original_total_duties_set
, o.total_weight
, o.source_name
, o.browser_ip
, o.buyer_accepts_marketing
, o.confirmed
, o.token
, o.cart_token
, o.checkout_token
, o.checkout_id
, o.customer_locale
, o.device_id
, o.landing_site_ref
, o.presentment_currency
, o.reference
, o.source_identifier
, o.source_url
, o._fivetran_deleted
, o.order_status_url
, o.test
, o.payment_gateway_names
, o.note_attributes
, o.client_details_user_agent
, o.landing_site_base_url
, o._fivetran_synced
, o.company_id
, o.company_location_id
FROM
  sellgoodr_canada_shopify."ORDER" o
UNION ALL
SELECT
  'Goodrwill'                                                         AS store
, o.id as order_id_shopify
, o.name as order_id_edw
, o.note
, o.email
, o.taxes_included
, o.currency
, o.subtotal_price
, o.subtotal_price_set
, o.total_tax as amount_tax_sold
, o.total_tax_set
, o.total_price as amount_sold
, o.total_price_set
, o.created_at
, o.updated_at
, o.shipping_address_name
, o.shipping_address_first_name
, o.shipping_address_last_name
, o.shipping_address_company
, o.shipping_address_phone
, o.shipping_address_address_1
, o.shipping_address_address_2
, o.shipping_address_city
, o.shipping_address_country
, o.shipping_address_country_code
, o.shipping_address_province
, o.shipping_address_province_code
, o.shipping_address_zip
, o.shipping_address_latitude
, o.shipping_address_longitude
, o.billing_address_name
, o.billing_address_first_name
, o.billing_address_last_name
, o.billing_address_company
, o.billing_address_phone
, o.billing_address_address_1
, o.billing_address_address_2
, o.billing_address_city
, o.billing_address_country
, o.billing_address_country_code
, o.billing_address_province
, o.billing_address_province_code
, o.billing_address_zip
, o.billing_address_latitude
, o.billing_address_longitude
, o.customer_id
, o.location_id
, o.user_id
, o.app_id
, o.number
, o.order_number
, o.financial_status
, o.fulfillment_status
, o.processed_at
, o.referring_site
, o.cancel_reason
, o.cancelled_at
, o.closed_at
, o.total_discounts as amount_discount
, o.total_tip_received
, o.current_total_price
, o.current_total_discounts
, o.current_subtotal_price
, o.current_total_tax
, o.current_total_discounts_set
, o.current_total_duties_set
, o.current_total_price_set
, o.current_subtotal_price_set
, o.current_total_tax_set
, o.total_discounts_set
, o.total_shipping_price_set
, o.total_line_items_price
, o.total_line_items_price_set
, o.original_total_duties_set
, o.total_weight
, o.source_name
, o.browser_ip
, o.buyer_accepts_marketing
, o.confirmed
, o.token
, o.cart_token
, o.checkout_token
, o.checkout_id
, o.customer_locale
, o.device_id
, o.landing_site_ref
, o.presentment_currency
, o.reference
, o.source_identifier
, o.source_url
, o._fivetran_deleted
, o.order_status_url
, o.test
, o.payment_gateway_names
, o.note_attributes
, o.client_details_user_agent
, o.landing_site_base_url
, o._fivetran_synced
, o.company_id
, o.company_location_id
FROM
  goodrwill_shopify."ORDER" o
UNION ALL
SELECT
  'Cabana'                                                            AS store
, o.id as order_id_shopify
, o.name as order_id_edw
, o.note
, o.email
, o.taxes_included
, o.currency
, o.subtotal_price
, o.subtotal_price_set
, o.total_tax as amount_tax_sold
, o.total_tax_set
, o.total_price as amount_sold
, o.total_price_set
, o.created_at
, o.updated_at
, o.shipping_address_name
, o.shipping_address_first_name
, o.shipping_address_last_name
, o.shipping_address_company
, o.shipping_address_phone
, o.shipping_address_address_1
, o.shipping_address_address_2
, o.shipping_address_city
, o.shipping_address_country
, o.shipping_address_country_code
, o.shipping_address_province
, o.shipping_address_province_code
, o.shipping_address_zip
, o.shipping_address_latitude
, o.shipping_address_longitude
, o.billing_address_name
, o.billing_address_first_name
, o.billing_address_last_name
, o.billing_address_company
, o.billing_address_phone
, o.billing_address_address_1
, o.billing_address_address_2
, o.billing_address_city
, o.billing_address_country
, o.billing_address_country_code
, o.billing_address_province
, o.billing_address_province_code
, o.billing_address_zip
, o.billing_address_latitude
, o.billing_address_longitude
, o.customer_id
, o.location_id
, o.user_id
, o.app_id
, o.number
, o.order_number
, o.financial_status
, o.fulfillment_status
, o.processed_at
, o.referring_site
, o.cancel_reason
, o.cancelled_at
, o.closed_at
, o.total_discounts as amount_discount
, o.total_tip_received
, o.current_total_price
, o.current_total_discounts
, o.current_subtotal_price
, o.current_total_tax
, o.current_total_discounts_set
, o.current_total_duties_set
, o.current_total_price_set
, o.current_subtotal_price_set
, o.current_total_tax_set
, o.total_discounts_set
, o.total_shipping_price_set
, o.total_line_items_price
, o.total_line_items_price_set
, o.original_total_duties_set
, o.total_weight
, o.source_name
, o.browser_ip
, o.buyer_accepts_marketing
, o.confirmed
, o.token
, o.cart_token
, o.checkout_token
, o.checkout_id
, o.customer_locale
, o.device_id
, o.landing_site_ref
, o.presentment_currency
, o.reference
, o.source_identifier
, o.source_url
, o._fivetran_deleted
, o.order_status_url
, o.test
, o.payment_gateway_names
, o.note_attributes
, o.client_details_user_agent
, o.landing_site_base_url
, o._fivetran_synced
, o.company_id
, o.company_location_id
FROM
  cabana."ORDER" o