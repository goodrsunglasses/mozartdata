SELECT
    us_returns_3p_warranties.id
    , us_returns_3p_warranties.created_at
    , us_returns_3p_warranties.approval_status
    , us_returns_3p_warranties.approved_at
    , us_returns_3p_warranties.auto_approved
    , us_returns_3p_warranties.auto_received
    , us_returns_3p_warranties.auto_refunded
    , us_returns_3p_warranties.auto_rejected
    , us_returns_3p_warranties.auto_resolved
    , us_returns_3p_warranties.checkout_total:AMOUNT::FLOAT as checkout_total
    , us_returns_3p_warranties.checkout_total:CURRENCY::STRING as checkout_currency
    , us_returns_3p_warranties.estimated_refund_total:AMOUNT::FLOAT as refund_amount
    , us_returns_3p_warranties.estimated_refund_total:CURRENCY::VARCHAR as refund_currency
    , us_returns_3p_warranties.exchange:EXCHANGE_TOTAL_INCLUDING_TAX:AMOUNT::FLOAT as exchange_total_incl_tax_amount
    , items_array.value:EXTERNAL_PRODUCT_ID::NUMBER as exchange_item_external_product_id
    , items_array.value:EXTERNAL_VARIANT_ID::NUMBER as exchange_item_external_variant_id
    , items_array.value:QUANTITY::NUMBER as exchange_item_quantity
    , items_array.value:SKU::VARCHAR as exchange_item_sku
    , items_array.value:TITLE::VARCHAR as exchange_item_title
    , items_array.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT as exchange_item_unit_price_amount
    , items_array.value:UNIT_DISPLAY_PRICE:CURRENCY::VARCHAR as exchange_item_unit_price_currency
    , items_array.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT as exchange_item_unit_price_amount
    , *
FROM
    aftership_returns_usa_and_3rd_party_warranties_portable.returns as us_returns_3p_warranties
        , LATERAL FLATTEN (
        input => us_returns_3p_warranties.exchange:ITEMS
    ) as items_array
WHERE
    ARRAY_SIZE(us_returns_3p_warranties.exchange:ITEMS) > 1