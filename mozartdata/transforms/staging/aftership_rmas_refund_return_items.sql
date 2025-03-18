SELECT 'USA - returns + 3rd party'                                              as aftership_org
     , us_returns_3p_warranties.id                                              as aftership_id
     , us_returns_3p_warranties.rma_number
     , us_returns_3p_warranties._order:ORDER_NUMBER::VARCHAR                    as original_order_id_edw
     , us_returns_3p_warranties._order:EXTERNAL_ID::INTEGER                     as original_order_id_shopify
     , return_items.value:SKU::VARCHAR                                          as return_item_product_id_edw
     , return_items.value:EXTERNAL_PRODUCT_ID::INTEGER                          as return_item_product_id_shopify
     , return_items.value:EXTERNAL_VARIANT_ID::INTEGER                          as return_item_variant_id_shopify
     , return_items.value:PRODUCT_TITLE::VARCHAR                                as return_item_title
     , return_items.value:PRODUCT_CATEGORIES[0]::VARCHAR                        as return_item_type
     , return_items.value:ORDERED_QUANTITY::INTEGER                             as ordered_quantity
     , return_items.value:INTENDED_RETURN_QUANTITY::INTEGER                     as intended_return_quantity
     , return_items.value:RETURN_QUANTITY::INTEGER                              as return_quantity
     , return_items.value:RECEIVED_QUANTITY::INTEGER                            as received_quantity
     , return_items.value:REFUND_QUANTITY::INTEGER                              as refund_quantity
     , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:AMOUNT::FLOAT     as return_item_total_price_amount
     , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:CURRENCY::VARCHAR as return_item_total_price_currency
     , return_items.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT                      as return_item_unit_price_amount
     , return_items.value:UNIT_DISPLAY_PRICE:CURRENCY::VARCHAR                  as return_item_unit_price_currency
     , return_items.value:UNIT_DISCOUNT:AMOUNT::FLOAT                           as return_item_shipping_price_amount
     , return_items.value:UNIT_DISCOUNT:CURRENCY::VARCHAR                       as return_item_shipping_price_currency
     , return_items.value:UNIT_TAX:AMOUNT::FLOAT                                as return_item_tax_price_amount
     , return_items.value:UNIT_TAX:CURRENCY::VARCHAR                            as return_item_tax_price_currency
     , return_items.value:RETURN_REASON::VARCHAR                                as return_item_reason
     , return_items.value:RETURN_SUBREASON::VARCHAR                             as return_item_subreason
     , return_items.value:RETURN_REASON_COMMENT::VARCHAR                        as return_item_reason_comment
     , return_items.value:PRODUCT_TAGS
FROM aftership_returns_usa_and_3rd_party_warranties_portable.returns as us_returns_3p_warranties
   , LATERAL FLATTEN(
        input => us_returns_3p_warranties.return_items
             ) as return_items
union all
SELECT 'Canada - returns + 3rd party'                                           as org
     , can_returns_3p_warranties.id                                             as aftership_id
     , can_returns_3p_warranties.rma_number
     , can_returns_3p_warranties._order:ORDER_NUMBER::VARCHAR                   as original_order_id_edw
     , can_returns_3p_warranties._order:EXTERNAL_ID::INTEGER                    as original_order_id_shopify
     , return_items.value:SKU::VARCHAR                                          as return_item_product_id_edw
     , return_items.value:EXTERNAL_PRODUCT_ID::INTEGER                          as return_item_product_id_shopify
     , return_items.value:EXTERNAL_VARIANT_ID::INTEGER                          as return_item_variant_id_shopify
     , return_items.value:PRODUCT_TITLE::VARCHAR                                as return_item_title
     , return_items.value:PRODUCT_CATEGORIES[0]::VARCHAR                        as return_item_type
     , return_items.value:ORDERED_QUANTITY::INTEGER                             as ordered_quantity
     , return_items.value:INTENDED_RETURN_QUANTITY::INTEGER                     as intended_return_quantity
     , return_items.value:RETURN_QUANTITY::INTEGER                              as return_quantity
     , return_items.value:RECEIVED_QUANTITY::INTEGER                            as received_quantity
     , return_items.value:REFUND_QUANTITY::INTEGER                              as refund_quantity
     , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:AMOUNT::FLOAT     as return_item_total_price_amount
     , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:CURRENCY::VARCHAR as return_item_total_price_currency
     , return_items.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT                      as return_item_unit_price_amount
     , return_items.value:UNIT_DISPLAY_PRICE:CURRENCY::VARCHAR                  as return_item_unit_price_currency
     , return_items.value:UNIT_DISCOUNT:AMOUNT::FLOAT                           as return_item_shipping_price_amount
     , return_items.value:UNIT_DISCOUNT:CURRENCY::VARCHAR                       as return_item_shipping_price_currency
     , return_items.value:UNIT_TAX:AMOUNT::FLOAT                                as return_item_tax_price_amount
     , return_items.value:UNIT_TAX:CURRENCY::VARCHAR                            as return_item_tax_price_currency
     , return_items.value:RETURN_REASON::VARCHAR                                as return_item_reason
     , return_items.value:RETURN_SUBREASON::VARCHAR                             as return_item_subreason
     , return_items.value:RETURN_REASON_COMMENT::VARCHAR                        as return_item_reason_comment
     , return_items.value:PRODUCT_TAGS
FROM aftership_returns_canada_and_3rd_party_warranties_portable.returns as can_returns_3p_warranties
   , LATERAL FLATTEN(
        input => can_returns_3p_warranties.return_items
             ) as return_items
union all
SELECT 'USA - warranty'                                                         as org
     , usa_warranties.id                                                        as aftership_id
     , usa_warranties.rma_number
     , usa_warranties._order:ORDER_NUMBER::VARCHAR                              as original_order_id_edw
     , usa_warranties._order:EXTERNAL_ID::INTEGER                               as original_order_id_shopify
     , return_items.value:SKU::VARCHAR                                          as return_item_product_id_edw
     , return_items.value:EXTERNAL_PRODUCT_ID::INTEGER                          as return_item_product_id_shopify
     , return_items.value:EXTERNAL_VARIANT_ID::INTEGER                          as return_item_variant_id_shopify
     , return_items.value:PRODUCT_TITLE::VARCHAR                                as return_item_title
     , return_items.value:PRODUCT_CATEGORIES[0]::VARCHAR                        as return_item_type
     , return_items.value:ORDERED_QUANTITY::INTEGER                             as ordered_quantity
     , return_items.value:INTENDED_RETURN_QUANTITY::INTEGER                     as intended_return_quantity
     , return_items.value:RETURN_QUANTITY::INTEGER                              as return_quantity
     , return_items.value:RECEIVED_QUANTITY::INTEGER                            as received_quantity
     , return_items.value:REFUND_QUANTITY::INTEGER                              as refund_quantity
     , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:AMOUNT::FLOAT     as return_item_total_price_amount
     , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:CURRENCY::VARCHAR as return_item_total_price_currency
     , return_items.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT                      as return_item_unit_price_amount
     , return_items.value:UNIT_DISPLAY_PRICE:CURRENCY::VARCHAR                  as return_item_unit_price_currency
     , return_items.value:UNIT_DISCOUNT:AMOUNT::FLOAT                           as return_item_shipping_price_amount
     , return_items.value:UNIT_DISCOUNT:CURRENCY::VARCHAR                       as return_item_shipping_price_currency
     , return_items.value:UNIT_TAX:AMOUNT::FLOAT                                as return_item_tax_price_amount
     , return_items.value:UNIT_TAX:CURRENCY::VARCHAR                            as return_item_tax_price_currency
     , return_items.value:RETURN_REASON::VARCHAR                                as return_item_reason
     , return_items.value:RETURN_SUBREASON::VARCHAR                             as return_item_subreason
     , return_items.value:RETURN_REASON_COMMENT::VARCHAR                        as return_item_reason_comment
     , return_items.value:PRODUCT_TAGS
FROM aftership_usa_warranties_portable.returns as usa_warranties
   , LATERAL FLATTEN(
        input => usa_warranties.return_items
             ) as return_items
union all
SELECT 'Canada - warranty'                                                      as org
     , can_warranties.id                                                        as aftership_id
     , can_warranties.rma_number
     , can_warranties._order:ORDER_NUMBER::VARCHAR                              as original_order_id_edw
     , can_warranties._order:EXTERNAL_ID::INTEGER                               as original_order_id_shopify
     , return_items.value:SKU::VARCHAR                                          as return_item_product_id_edw
     , return_items.value:EXTERNAL_PRODUCT_ID::INTEGER                          as return_item_product_id_shopify
     , return_items.value:EXTERNAL_VARIANT_ID::INTEGER                          as return_item_variant_id_shopify
     , return_items.value:PRODUCT_TITLE::VARCHAR                                as return_item_title
     , return_items.value:PRODUCT_CATEGORIES[0]::VARCHAR                        as return_item_type
     , return_items.value:ORDERED_QUANTITY::INTEGER                             as ordered_quantity
     , return_items.value:INTENDED_RETURN_QUANTITY::INTEGER                     as intended_return_quantity
     , return_items.value:RETURN_QUANTITY::INTEGER                              as return_quantity
     , return_items.value:RECEIVED_QUANTITY::INTEGER                            as received_quantity
     , return_items.value:REFUND_QUANTITY::INTEGER                              as refund_quantity
     , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:AMOUNT::FLOAT     as return_item_total_price_amount
     , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:CURRENCY::VARCHAR as return_item_total_price_currency
     , return_items.value:UNIT_DISPLAY_PRICE:AMOUNT::FLOAT                      as return_item_unit_price_amount
     , return_items.value:UNIT_DISPLAY_PRICE:CURRENCY::VARCHAR                  as return_item_unit_price_currency
     , return_items.value:UNIT_DISCOUNT:AMOUNT::FLOAT                           as return_item_shipping_price_amount
     , return_items.value:UNIT_DISCOUNT:CURRENCY::VARCHAR                       as return_item_shipping_price_currency
     , return_items.value:UNIT_TAX:AMOUNT::FLOAT                                as return_item_tax_price_amount
     , return_items.value:UNIT_TAX:CURRENCY::VARCHAR                            as return_item_tax_price_currency
     , return_items.value:RETURN_REASON::VARCHAR                                as return_item_reason
     , return_items.value:RETURN_SUBREASON::VARCHAR                             as return_item_subreason
     , return_items.value:RETURN_REASON_COMMENT::VARCHAR                        as return_item_reason_comment
     , return_items.value:PRODUCT_TAGS
FROM aftership_canada_warranties_portable.returns as can_warranties
   , LATERAL FLATTEN(
        input => can_warranties.return_items
             ) as return_items