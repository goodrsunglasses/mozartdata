/*
    Table name:
        staging.aftership_rmas_refund_return_items
    Created:
        3-12-2025
    Purpose:
        Union alls together the item-level refund and return data from the various Portable Aftership tables
        - USA + 3rd Party, Canada + 3rd Party, US Warranty, and Canada Warranty. It does not actually have any 3rd party
        warranty data as of its creation due to that information not flowing through the API - it requires
        webhooks, which can be implemented in the future if desired.

        To be clear on the difference between this and the exchange_warranty_items table: this table shows information
        related to items being refunded for or returned.

    Schema:
        org_id_aftership: id of the organization (created in dwh since we don't get from Portable)
            Composite primary Key with rma_id_aftership and original_item_aftership_id
        org_name_aftership: The organization on Aftership
        rma_id_aftership: unique id of rma on Aftership
            Composite primary Key with original_item_aftership_id and org_id_aftership
        rma_number_aftership: the main identifier for an Aftership customer request within an Aftership organization
        original_order_id_edw:the order number of the original order that is associated with the RMA.
            Foreign key to fact.orders.order_id_edw and fact.aftership_rmas.original_order_id_edw
        original_order_id_shopify: id as it is shows in the address bar when viewing it on the shopify website
        return_item_aftership_id: item id in the return.
            Composite primary Key with rma_id_aftership and org_id_aftership
        return_item_product_id_edw: product_id_edw (sku) of the item being returned/refunded
        return_item_product_id_shopify: product id in shopify of the item being returned/refunded
        return_item_variant_id_shopify: variant id in shopify of the item being returned/refunded
        return_item_display_name: display name of the item being returned
        return_item_type: collection that return item belongs to, e.g. The OGs
        ordered_quantity: quantity originally ordered of this item
        intended_return_quantity: quantity listed on the return as going to be returned/refunded
        return_quantity: quantity actually returned/refunded
        received_quantity: quantity received per shipping info. Very inaccurate
        refund_quantity: quantity actually refunded
        return_item_total_price_amount: return item total original price with tax
        return_item_total_price_currency: currency return item total price is in.
        return_item_unit_price_amount: normal price of the item being returned
        return_item_unit_price_currency: currency of unit price
        return_item_unit_discount_amount: discount applied to normal price of item being returned.
            Not necessarily applied to the item in Shopify - could be shipping discount broken down by
            item by Aftership.
        return_item_unit_discount_currency: Currency of discount
        return_item_tax_price_amount: tax value of original item in original order.
        return_item_tax_price_currency: currency of tax
        return_item_reason: reason item is returned
        return_item_subreason: subreason it is returned
        return_item_reason_comment: comment for return item. This contains date code for warranties
        PRODUCT_TAGS: tags on product. random but useful data that is not normalized
 */

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )

select
    1                                                                        as org_id_aftership
  , 'USA - returns + 3rd party'                                              as org_name_aftership
  , us_returns_3p_warranties.id                                              as rma_id_aftership
  , us_returns_3p_warranties.rma_number                                      as rma_number_aftership
  , us_returns_3p_warranties._order:ORDER_NUMBER::varchar                    as original_order_id_edw
  , us_returns_3p_warranties._order:EXTERNAL_ID::integer                     as original_order_id_shopify
  , return_items.value:ID::integer                                           as return_item_aftership_id
  , return_items.value:SKU::varchar                                          as return_item_product_id_edw
  , return_items.value:EXTERNAL_PRODUCT_ID::integer                          as return_item_product_id_shopify
  , return_items.value:EXTERNAL_VARIANT_ID::integer                          as return_item_variant_id_shopify
  , return_items.value:PRODUCT_TITLE::varchar                                as return_item_display_name
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
    2                                                                        as org_id_aftership
  , 'Canada - returns + 3rd party'                                           as org_name_aftership
  , can_returns_3p_warranties.id                                             as rma_id_aftership
  , can_returns_3p_warranties.rma_number                                     as rma_number_aftership
  , can_returns_3p_warranties._order:ORDER_NUMBER::varchar                   as original_order_id_edw
  , can_returns_3p_warranties._order:EXTERNAL_ID::integer                    as original_order_id_shopify
  , return_items.value:ID::integer                                           as return_item_aftership_id
  , return_items.value:SKU::varchar                                          as return_item_product_id_edw
  , return_items.value:EXTERNAL_PRODUCT_ID::integer                          as return_item_product_id_shopify
  , return_items.value:EXTERNAL_VARIANT_ID::integer                          as return_item_variant_id_shopify
  , return_items.value:PRODUCT_TITLE::varchar                                as return_item_display_name
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
    3                                                                        as org_id_aftership
  , 'USA - warranty'                                                         as org_name_aftership
  , usa_warranties.id                                                        as rma_id_aftership
  , usa_warranties.rma_number                                                as rma_number_aftership
  , usa_warranties._order:ORDER_NUMBER::varchar                              as original_order_id_edw
  , usa_warranties._order:EXTERNAL_ID::integer                               as original_order_id_shopify
  , return_items.value:ID::integer                                           as return_item_aftership_id
  , return_items.value:SKU::varchar                                          as return_item_product_id_edw
  , return_items.value:EXTERNAL_PRODUCT_ID::integer                          as return_item_product_id_shopify
  , return_items.value:EXTERNAL_VARIANT_ID::integer                          as return_item_variant_id_shopify
  , return_items.value:PRODUCT_TITLE::varchar                                as return_item_display_name
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
    4                                                                        as org_id_aftership
  , 'Canada - warranty'                                                      as org_name_aftership
  , can_warranties.id                                                        as rma_id_aftership
  , can_warranties.rma_number                                                as rma_number_aftership
  , can_warranties._order:ORDER_NUMBER::varchar                              as original_order_id_edw
  , can_warranties._order:EXTERNAL_ID::integer                               as original_order_id_shopify
  , return_items.value:ID::integer                                           as return_item_aftership_id
  , return_items.value:SKU::varchar                                          as return_item_product_id_edw
  , return_items.value:EXTERNAL_PRODUCT_ID::integer                          as return_item_product_id_shopify
  , return_items.value:EXTERNAL_VARIANT_ID::integer                          as return_item_variant_id_shopify
  , return_items.value:PRODUCT_TITLE::varchar                                as return_item_display_name
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