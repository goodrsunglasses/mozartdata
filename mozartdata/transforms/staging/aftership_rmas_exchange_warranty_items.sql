SELECT
    'USA - Returns + 3rd party' as aftership_org
    , us_returns_3p_warranties.id as aftership_id
    , us_returns_3p_warranties.rma_number
    , us_returns_3p_warranties._order:ORDER_NUMBER::VARCHAR as original_order_id_edw
    , us_returns_3p_warranties._order:EXTERNAL_ID::INTEGER as original_order_id_shopify
    , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_PRODUCT_ID::INTEGER as original_item_product_id_shopify
    , exchange_items.value:VARIANT_TO_REPLACE:SKU::VARCHAR as original_item_product_id_edw
    , exchange_items.value:VARIANT_TO_REPLACE:TITLE::VARCHAR as original_item_title
    , exchange_items.value:SKU::VARCHAR as exchange_item_product_id_edw
    , exchange_items.value:EXTERNAL_PRODUCT_ID::INTEGER as exchange_item_product_id_shopify
    , exchange_items.value:EXTERNAL_VARIANT_ID::INTEGER as exchange_item_variant_id_shopify
    , exchange_items.value:QUANTITY::INTEGER as exchange_quantity
    , exchange_items.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT as exchange_item_unit_price_amount
    , exchange_items.value:UNIT_DISPLAY_PRICE:CURRENCY::VARCHAR as exchange_item_unit_price_currency
FROM
    aftership_returns_usa_and_3rd_party_warranties_portable.returns as us_returns_3p_warranties
    , LATERAL FLATTEN (
        input => us_returns_3p_warranties.exchange:ITEMS
    ) as exchange_items
WHERE
    lower(us_returns_3p_warranties.exchange) != 'null'
union all
SELECT
    'Canada - Returns + 3rd party' as org
    , can_returns_3p_warranties.id as aftership_id
    , can_returns_3p_warranties.rma_number
    , can_returns_3p_warranties._order:ORDER_NUMBER::VARCHAR as original_order_id_edw
    , can_returns_3p_warranties._order:EXTERNAL_ID::INTEGER as original_order_id_shopify
    , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_PRODUCT_ID::INTEGER as original_item_product_id_shopify
    , exchange_items.value:VARIANT_TO_REPLACE:SKU::VARCHAR as original_item_product_id_edw
    , exchange_items.value:VARIANT_TO_REPLACE:TITLE::VARCHAR as original_item_title
    , exchange_items.value:SKU::VARCHAR as exchange_item_product_id_edw
    , exchange_items.value:EXTERNAL_PRODUCT_ID::INTEGER as exchange_item_product_id_shopify
    , exchange_items.value:EXTERNAL_VARIANT_ID::INTEGER as exchange_item_variant_id_shopify
    , exchange_items.value:QUANTITY::INTEGER as exchange_quantity
    , exchange_items.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT as exchange_item_unit_price_amount
    , exchange_items.value:UNIT_DISPLAY_PRICE:CURRENCY::VARCHAR as exchange_item_unit_price_currency
FROM
    aftership_returns_canada_and_3rd_party_warranties_portable.returns as can_returns_3p_warranties
    , LATERAL FLATTEN (
        input => can_returns_3p_warranties.exchange:ITEMS
    ) as exchange_items
WHERE
    lower(can_returns_3p_warranties.exchange) != 'null'
union all
SELECT
    'USA - warranty' as org
    , usa_warranties.id as aftership_id
    , usa_warranties.rma_number
    , usa_warranties._order:ORDER_NUMBER::VARCHAR as original_order_id_edw
    , usa_warranties._order:EXTERNAL_ID::INTEGER as original_order_id_shopify
    , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_PRODUCT_ID::INTEGER as original_item_product_id_shopify
    , exchange_items.value:VARIANT_TO_REPLACE:SKU::VARCHAR as original_item_product_id_edw
    , exchange_items.value:VARIANT_TO_REPLACE:TITLE::VARCHAR as original_item_title
    , exchange_items.value:SKU::VARCHAR as exchange_item_product_id_edw
    , exchange_items.value:EXTERNAL_PRODUCT_ID::INTEGER as exchange_item_product_id_shopify
    , exchange_items.value:EXTERNAL_VARIANT_ID::INTEGER as exchange_item_variant_id_shopify
    , exchange_items.value:QUANTITY::INTEGER as exchange_quantity
    , exchange_items.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT as exchange_item_unit_price_amount
    , exchange_items.value:UNIT_DISPLAY_PRICE:CURRENCY::VARCHAR as exchange_item_unit_price_currency
FROM
    aftership_usa_warranties_portable.returns as usa_warranties
    , LATERAL FLATTEN (
        input => usa_warranties.exchange:ITEMS
    ) as exchange_items
WHERE
    lower(usa_warranties.exchange) != 'null'
union all
SELECT
    'Canada - warranty' as org
    , can_warranties.id as aftership_id
    , can_warranties.rma_number
    , can_warranties._order:ORDER_NUMBER::VARCHAR as original_order_id_edw
    , can_warranties._order:EXTERNAL_ID::INTEGER as original_order_id_shopify
    , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_PRODUCT_ID::INTEGER as original_item_product_id_shopify
    , exchange_items.value:VARIANT_TO_REPLACE:SKU::VARCHAR as original_item_product_id_edw
    , exchange_items.value:VARIANT_TO_REPLACE:TITLE::VARCHAR as original_item_title
    , exchange_items.value:SKU::VARCHAR as exchange_item_product_id_edw
    , exchange_items.value:EXTERNAL_PRODUCT_ID::INTEGER as exchange_item_product_id_shopify
    , exchange_items.value:EXTERNAL_VARIANT_ID::INTEGER as exchange_item_variant_id_shopify
    , exchange_items.value:QUANTITY::INTEGER as exchange_quantity
    , exchange_items.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT as exchange_item_unit_price_amount
    , exchange_items.value:UNIT_DISPLAY_PRICE:CURRENCY::VARCHAR as exchange_item_unit_price_currency
FROM
    aftership_canada_warranties_portable.returns as can_warranties
    , LATERAL FLATTEN (
        input => can_warranties.exchange:ITEMS
    ) as exchange_items
WHERE
    lower(can_warranties.exchange) != 'null'