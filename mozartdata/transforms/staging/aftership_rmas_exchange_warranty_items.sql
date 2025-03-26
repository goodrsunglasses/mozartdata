/*
    Table name:
        staging.aftership_rmas_exchange_warranty_items
    Created:
        3-12-2025
    Purpose:
        Union alls together the item-level warranty and exchange data from the various Portable Aftership tables
        - USA + 3rd Party, Canada + 3rd Party, US Warranty, and Canada Warranty. It does not actually have any 3rd party
        warranty data as of its creation due to that information not flowing through the API - it requires
        webhooks, which can be implemented in the future if desired.

        To be clear on the difference between this and the refund_return_items table: this table shows information
        related to items being sent to a customer (an exchange).

    Schema:
        org_id_aftership: id of the organization (created in dwh since we don't get from Portable)
            Composite primary Key with rma_id_aftership and org_id_aftership
        org_name_aftership: The organization on Aftership
        rma_id_aftership: unique id of rma on Aftership
            Composite primary Key with original_item_aftership_id and org_id_aftership
        rma_number_aftership: the main identifier for an Aftership customer request within an Aftership organization
        original_order_id_edw: the order number of the original order that is associated with the RMA.
            Foreign key to fact.orders.order_id_edw and fact.aftership_rmas.original_order_id_edw
        original_order_id_shopify: id as it is shows in the address bar when viewing it on the shopify website
        original_item_aftership_id: unique aftership id of the originally ordered item that the exchange is replacing
            Composite primary Key with rma_id_aftership and org_id_aftership
        original_item_product_id_edw: product_id_edw (sku) of the item being replaced in the exchange
        original_item_product_id_shopify: product_id in shopify of the item being replaced in the exchange
        original_item_display_name: display name of the item being replaced in the exchange
        exchange_item_product_id_edw: product_id_edw (sku) of the item being used as a replacement in the exchange
        exchange_item_product_id_shopify: product_id in shopify of the item being used as a replacement in the exchange
        exchange_item_variant_id_shopify: variant_id in Shopify of the item being used as a replacement in the exchange
        exchange_quantity: quantity being sent in the exchange
        exchange_item_unit_price_amount: cost of the item being used as a replacement if it were bought instead
        exchange_item_unit_price_currency: currency of the unit price
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )

select
    1                                                                    as org_id_aftership
  , 'USA - returns + 3rd party'                                          as org_name_aftership
  , us_returns_3p_warranties.id                                          as rma_id_aftership
  , us_returns_3p_warranties.rma_number                                  as rma_number_aftership
  , us_returns_3p_warranties._order:ORDER_NUMBER::varchar                as original_order_id_edw
  , us_returns_3p_warranties._order:EXTERNAL_ID::integer                 as original_order_id_shopify
  , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_ID::integer         as original_item_aftership_id
  , exchange_items.value:VARIANT_TO_REPLACE:SKU::varchar                 as original_item_product_id_edw
  , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_PRODUCT_ID::integer as original_item_product_id_shopify
  , exchange_items.value:VARIANT_TO_REPLACE:TITLE::varchar               as original_item_display_name
  , exchange_items.value:SKU::varchar                                    as exchange_item_product_id_edw
  , exchange_items.value:EXTERNAL_PRODUCT_ID::integer                    as exchange_item_product_id_shopify
  , exchange_items.value:EXTERNAL_VARIANT_ID::integer                    as exchange_item_variant_id_shopify
  , exchange_items.value:QUANTITY::integer                               as exchange_quantity
  , exchange_items.value:UNIT_DISPLAY_PRICE:AMOUNT::float                as exchange_item_unit_price_amount
  , exchange_items.value:UNIT_DISPLAY_PRICE:CURRENCY::varchar            as exchange_item_unit_price_currency
from
    aftership_returns_usa_and_3rd_party_warranties_portable.returns as us_returns_3p_warranties
  , lateral flatten(
    input => us_returns_3p_warranties.exchange:ITEMS
            )                                                       as exchange_items
union all
select
    2                                                                    as org_id_aftership
  , 'Canada - returns + 3rd party'                                       as org_name_aftership
  , can_returns_3p_warranties.id                                         as rma_id_aftership
  , can_returns_3p_warranties.rma_number                                 as rma_number_aftership
  , can_returns_3p_warranties._order:ORDER_NUMBER::varchar               as original_order_id_edw
  , can_returns_3p_warranties._order:EXTERNAL_ID::integer                as original_order_id_shopify
  , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_ID::integer         as original_item_aftership_id
  , exchange_items.value:VARIANT_TO_REPLACE:SKU::varchar                 as original_item_product_id_edw
  , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_PRODUCT_ID::integer as original_item_product_id_shopify
  , exchange_items.value:VARIANT_TO_REPLACE:TITLE::varchar               as original_item_display_name
  , exchange_items.value:SKU::varchar                                    as exchange_item_product_id_edw
  , exchange_items.value:EXTERNAL_PRODUCT_ID::integer                    as exchange_item_product_id_shopify
  , exchange_items.value:EXTERNAL_VARIANT_ID::integer                    as exchange_item_variant_id_shopify
  , exchange_items.value:QUANTITY::integer                               as exchange_quantity
  , exchange_items.value:UNIT_DISPLAY_PRICE:AMOUNT::float                as exchange_item_unit_price_amount
  , exchange_items.value:UNIT_DISPLAY_PRICE:CURRENCY::varchar            as exchange_item_unit_price_currency
from
    aftership_returns_canada_and_3rd_party_warranties_portable.returns as can_returns_3p_warranties
  , lateral flatten(
    input => can_returns_3p_warranties.exchange:ITEMS
            )                                                          as exchange_items
union all
select
    3                                                                    as org_id_aftership
  , 'USA - warranty'                                                     as org_name_aftership
  , usa_warranties.id                                                    as rma_id_aftership
  , usa_warranties.rma_number                                            as rma_number_aftership
  , usa_warranties._order:ORDER_NUMBER::varchar                          as original_order_id_edw
  , usa_warranties._order:EXTERNAL_ID::integer                           as original_order_id_shopify
  , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_ID::integer         as original_item_aftership_id
  , exchange_items.value:VARIANT_TO_REPLACE:SKU::varchar                 as original_item_product_id_edw
  , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_PRODUCT_ID::integer as original_item_product_id_shopify
  , exchange_items.value:VARIANT_TO_REPLACE:TITLE::varchar               as original_item_display_name
  , exchange_items.value:SKU::varchar                                    as exchange_item_product_id_edw
  , exchange_items.value:EXTERNAL_PRODUCT_ID::integer                    as exchange_item_product_id_shopify
  , exchange_items.value:EXTERNAL_VARIANT_ID::integer                    as exchange_item_variant_id_shopify
  , exchange_items.value:QUANTITY::integer                               as exchange_quantity
  , exchange_items.value:UNIT_DISPLAY_PRICE:AMOUNT::float                as exchange_item_unit_price_amount
  , exchange_items.value:UNIT_DISPLAY_PRICE:CURRENCY::varchar            as exchange_item_unit_price_currency
from
    aftership_usa_warranties_portable.returns as usa_warranties
  , lateral flatten(
    input => usa_warranties.exchange:ITEMS
            )                                 as exchange_items
union all
select
    4                                                                    as org_id_aftership
  , 'Canada - warranty'                                                  as org_name_aftership
  , can_warranties.id                                                    as rma_id_aftership
  , can_warranties.rma_number                                            as rma_number_aftership
  , can_warranties._order:ORDER_NUMBER::varchar                          as original_order_id_edw
  , can_warranties._order:EXTERNAL_ID::integer                           as original_order_id_shopify
  , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_ID::integer         as original_item_aftership_id
  , exchange_items.value:VARIANT_TO_REPLACE:SKU::varchar                 as original_item_product_id_edw
  , exchange_items.value:VARIANT_TO_REPLACE:EXTERNAL_PRODUCT_ID::integer as original_item_product_id_shopify
  , exchange_items.value:VARIANT_TO_REPLACE:TITLE::varchar               as original_item_display_name
  , exchange_items.value:SKU::varchar                                    as exchange_item_product_id_edw
  , exchange_items.value:EXTERNAL_PRODUCT_ID::integer                    as exchange_item_product_id_shopify
  , exchange_items.value:EXTERNAL_VARIANT_ID::integer                    as exchange_item_variant_id_shopify
  , exchange_items.value:QUANTITY::integer                               as exchange_quantity
  , exchange_items.value:UNIT_DISPLAY_PRICE:AMOUNT::float                as exchange_item_unit_price_amount
  , exchange_items.value:UNIT_DISPLAY_PRICE:CURRENCY::varchar            as exchange_item_unit_price_currency
from
    aftership_canada_warranties_portable.returns as can_warranties
  , lateral flatten(
    input => can_warranties.exchange:ITEMS
            )                                    as exchange_items