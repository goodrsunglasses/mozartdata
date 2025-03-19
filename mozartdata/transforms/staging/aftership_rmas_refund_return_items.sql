select
    'USA - returns + 3rd party'                                              as aftership_org
  , us_returns_3p_warranties.id                                              as aftership_id
  , us_returns_3p_warranties.rma_number
  , us_returns_3p_warranties._order:ORDER_NUMBER::varchar                    as original_order_id_edw
  , us_returns_3p_warranties._order:EXTERNAL_ID::integer                     as original_order_id_shopify
  , return_items.value:SKU::varchar                                          as return_item_product_id_edw
  , return_items.value:EXTERNAL_PRODUCT_ID::integer                          as return_item_product_id_shopify
  , return_items.value:EXTERNAL_VARIANT_ID::integer                          as return_item_variant_id_shopify
  , return_items.value:PRODUCT_TITLE::varchar                                as return_item_title
  , return_items.value:PRODUCT_CATEGORIES[0]::varchar                        as return_item_type
  , return_items.value:ORDERED_QUANTITY::integer                             as ordered_quantity
  , return_items.value:INTENDED_RETURN_QUANTITY::integer                     as intended_return_quantity
  , return_items.value:RETURN_QUANTITY::integer                              as return_quantity
  , return_items.value:RECEIVED_QUANTITY::integer                            as received_quantity
  , return_items.value:REFUND_QUANTITY::integer                              as refund_quantity
  , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:AMOUNT::float     as return_item_total_price_amount
  , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:CURRENCY::varchar as return_item_total_price_currency
  , return_items.value:UNIT_DISPLAY_PRICE:AMOUNT::float                      as return_item_unit_price_amount
  , return_items.value:UNIT_DISPLAY_PRICE:CURRENCY::varchar                  as return_item_unit_price_currency
  , return_items.value:UNIT_DISCOUNT:AMOUNT::float                           as return_item_unit_discount_amount
  , return_items.value:UNIT_DISCOUNT:CURRENCY::varchar                       as return_item_unit_discount_currency
  , return_items.value:UNIT_TAX:AMOUNT::float                                as return_item_tax_price_amount
  , return_items.value:UNIT_TAX:CURRENCY::varchar                            as return_item_tax_price_currency
  , return_items.value:RETURN_REASON::varchar                                as return_item_reason
  , return_items.value:RETURN_SUBREASON::varchar                             as return_item_subreason
  , return_items.value:RETURN_REASON_COMMENT::varchar                        as return_item_reason_comment
  , return_items.value:PRODUCT_TAGS
from
    aftership_returns_usa_and_3rd_party_warranties_portable.returns as us_returns_3p_warranties
  , lateral flatten(
    input => us_returns_3p_warranties.return_items
            )                                                       as return_items
union all
select
    'Canada - returns + 3rd party'                                           as org
  , can_returns_3p_warranties.id                                             as aftership_id
  , can_returns_3p_warranties.rma_number
  , can_returns_3p_warranties._order:ORDER_NUMBER::varchar                   as original_order_id_edw
  , can_returns_3p_warranties._order:EXTERNAL_ID::integer                    as original_order_id_shopify
  , return_items.value:SKU::varchar                                          as return_item_product_id_edw
  , return_items.value:EXTERNAL_PRODUCT_ID::integer                          as return_item_product_id_shopify
  , return_items.value:EXTERNAL_VARIANT_ID::integer                          as return_item_variant_id_shopify
  , return_items.value:PRODUCT_TITLE::varchar                                as return_item_title
  , return_items.value:PRODUCT_CATEGORIES[0]::varchar                        as return_item_type
  , return_items.value:ORDERED_QUANTITY::integer                             as ordered_quantity
  , return_items.value:INTENDED_RETURN_QUANTITY::integer                     as intended_return_quantity
  , return_items.value:RETURN_QUANTITY::integer                              as return_quantity
  , return_items.value:RECEIVED_QUANTITY::integer                            as received_quantity
  , return_items.value:REFUND_QUANTITY::integer                              as refund_quantity
  , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:AMOUNT::float     as return_item_total_price_amount
  , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:CURRENCY::varchar as return_item_total_price_currency
  , return_items.value:UNIT_DISPLAY_PRICE:AMOUNT::float                      as return_item_unit_price_amount
  , return_items.value:UNIT_DISPLAY_PRICE:CURRENCY::varchar                  as return_item_unit_price_currency
  , return_items.value:UNIT_DISCOUNT:AMOUNT::float                           as return_item_unit_discount_amount
  , return_items.value:UNIT_DISCOUNT:CURRENCY::varchar                       as return_item_unit_discount_currency
  , return_items.value:UNIT_TAX:AMOUNT::float                                as return_item_tax_price_amount
  , return_items.value:UNIT_TAX:CURRENCY::varchar                            as return_item_tax_price_currency
  , return_items.value:RETURN_REASON::varchar                                as return_item_reason
  , return_items.value:RETURN_SUBREASON::varchar                             as return_item_subreason
  , return_items.value:RETURN_REASON_COMMENT::varchar                        as return_item_reason_comment
  , return_items.value:PRODUCT_TAGS
from
    aftership_returns_canada_and_3rd_party_warranties_portable.returns as can_returns_3p_warranties
  , lateral flatten(
    input => can_returns_3p_warranties.return_items
            )                                                          as return_items
union all
select
    'USA - warranty'                                                         as org
  , usa_warranties.id                                                        as aftership_id
  , usa_warranties.rma_number
  , usa_warranties._order:ORDER_NUMBER::varchar                              as original_order_id_edw
  , usa_warranties._order:EXTERNAL_ID::integer                               as original_order_id_shopify
  , return_items.value:SKU::varchar                                          as return_item_product_id_edw
  , return_items.value:EXTERNAL_PRODUCT_ID::integer                          as return_item_product_id_shopify
  , return_items.value:EXTERNAL_VARIANT_ID::integer                          as return_item_variant_id_shopify
  , return_items.value:PRODUCT_TITLE::varchar                                as return_item_title
  , return_items.value:PRODUCT_CATEGORIES[0]::varchar                        as return_item_type
  , return_items.value:ORDERED_QUANTITY::integer                             as ordered_quantity
  , return_items.value:INTENDED_RETURN_QUANTITY::integer                     as intended_return_quantity
  , return_items.value:RETURN_QUANTITY::integer                              as return_quantity
  , return_items.value:RECEIVED_QUANTITY::integer                            as received_quantity
  , return_items.value:REFUND_QUANTITY::integer                              as refund_quantity
  , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:AMOUNT::float     as return_item_total_price_amount
  , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:CURRENCY::varchar as return_item_total_price_currency
  , return_items.value:UNIT_DISPLAY_PRICE:AMOUNT::float                      as return_item_unit_price_amount
  , return_items.value:UNIT_DISPLAY_PRICE:CURRENCY::varchar                  as return_item_unit_price_currency
  , return_items.value:UNIT_DISCOUNT:AMOUNT::float                           as return_item_unit_discount_amount
  , return_items.value:UNIT_DISCOUNT:CURRENCY::varchar                       as return_item_unit_discount_currency
  , return_items.value:UNIT_TAX:AMOUNT::float                                as return_item_tax_price_amount
  , return_items.value:UNIT_TAX:CURRENCY::varchar                            as return_item_tax_price_currency
  , return_items.value:RETURN_REASON::varchar                                as return_item_reason
  , return_items.value:RETURN_SUBREASON::varchar                             as return_item_subreason
  , return_items.value:RETURN_REASON_COMMENT::varchar                        as return_item_reason_comment
  , return_items.value:PRODUCT_TAGS
from
    aftership_usa_warranties_portable.returns as usa_warranties
  , lateral flatten(
    input => usa_warranties.return_items
            )                                 as return_items
union all
select
    'Canada - warranty'                                                      as org
  , can_warranties.id                                                        as aftership_id
  , can_warranties.rma_number
  , can_warranties._order:ORDER_NUMBER::varchar                              as original_order_id_edw
  , can_warranties._order:EXTERNAL_ID::integer                               as original_order_id_shopify
  , return_items.value:SKU::varchar                                          as return_item_product_id_edw
  , return_items.value:EXTERNAL_PRODUCT_ID::integer                          as return_item_product_id_shopify
  , return_items.value:EXTERNAL_VARIANT_ID::integer                          as return_item_variant_id_shopify
  , return_items.value:PRODUCT_TITLE::varchar                                as return_item_title
  , return_items.value:PRODUCT_CATEGORIES[0]::varchar                        as return_item_type
  , return_items.value:ORDERED_QUANTITY::integer                             as ordered_quantity
  , return_items.value:INTENDED_RETURN_QUANTITY::integer                     as intended_return_quantity
  , return_items.value:RETURN_QUANTITY::integer                              as return_quantity
  , return_items.value:RECEIVED_QUANTITY::integer                            as received_quantity
  , return_items.value:REFUND_QUANTITY::integer                              as refund_quantity
  , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:AMOUNT::float     as return_item_total_price_amount
  , return_items.value:UNIT_DISCOUNTED_PRICE_INCLUDING_TAX:CURRENCY::varchar as return_item_total_price_currency
  , return_items.value:UNIT_DISPLAY_PRICE:AMOUNT::float                      as return_item_unit_price_amount
  , return_items.value:UNIT_DISPLAY_PRICE:CURRENCY::varchar                  as return_item_unit_price_currency
  , return_items.value:UNIT_DISCOUNT:AMOUNT::float                           as return_item_unit_discount_amount
  , return_items.value:UNIT_DISCOUNT:CURRENCY::varchar                       as return_item_unit_discount_currency
  , return_items.value:UNIT_TAX:AMOUNT::float                                as return_item_tax_price_amount
  , return_items.value:UNIT_TAX:CURRENCY::varchar                            as return_item_tax_price_currency
  , return_items.value:RETURN_REASON::varchar                                as return_item_reason
  , return_items.value:RETURN_SUBREASON::varchar                             as return_item_subreason
  , return_items.value:RETURN_REASON_COMMENT::varchar                        as return_item_reason_comment
  , return_items.value:PRODUCT_TAGS
from
    aftership_canada_warranties_portable.returns as can_warranties
  , lateral flatten(
    input => can_warranties.return_items
            )                                    as return_items