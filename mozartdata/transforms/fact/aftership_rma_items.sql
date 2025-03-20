/*
    Table name: fact.aftership_rma_items
    Created: 3-14-2025
    Purpose: takes information from staging.aftership_rmas_refund_return_items and
        aftership_rmas_exchange_warranty_items and creates a table for determining item-level info in rmas, e.g. sku,
        quantity and value. Links to dim.product to provide info on parts like lens, frame and vendor. each row contains
        the item returned and any items it was exchanged for, if any.

    Schema:
        aftership_id: The organization on Aftership
        rma_number: the main identifier for an Aftership customer request.
        rma_created_date: date rma was created
        rma_email: email of the customer that submitted the rma
        original_order_id_edw:  the order number of the original order that is associated with the RMA.
            Foreign key to fact.orders.order_id_edw and fact.aftership_rmas.original_order_id_edw
        original_order_date: date that the original order was placed
        rma_type: whether a item is part of a refund, an exchange or a warranty. NOT THE SAME AS fact.aftership_rmas
        rma_return_type: what type of return is the item - return or no return
        rma_item_product_id_edw: product_id_edw (sku) of the item
        rma_item_product_id_shopify: product id in Shopify of the item
        rma_item_variant_id_shopify: variant id in Shopify of the item
        rma_item_title: display name of item
        rma_item_type: collection of item, e.g. the OGs
        rma_item_reason: reason item is being returned
        rma_item_subreason: subreason item is being returned
        rma_item_reason_comment: comment on item being returned. Contains date code
        original_ordered_item_quantity: original ordered item quantity
        rma_item_quantity: quantity being subitted in the rma
        rma_item_currency: currency of item values
        rma_item_product_value: value of product in original order, MAY NOT HAVE BEEN WHAT WAS CHARGED
        rma_item_discount_value: value of discount on item in original order, MAY NOT HAVE BEEN ITEM LEVEL IN
            ORIGINAL ORDER
        rma_item_tax_value: value of tax on item in the original order
        rma_item_collection: collection of item per dim.product
        rma_item_family: family of item per dim.product
        rma_item_stage: stage of item per dim.product
        rma_item_merchandise_class: class of item per dim.product
        rma_item_upc_code: upc code of item per dim.product
        rma_item_design_tier: design tier of item per dim.product
        rma_item_lens_sku: lens sku per dim.product
        rma_item_lens_type: lens type per dim.product
        rma_item_color_frame: frame color per dim.product
        rma_item_frame_artwork: frame artwork per dim.product
        rma_item_frame_finish: frame finish per dim.product
        rma_item_vendor_name: vendor per dim.product
        rma_exchange_item_product_id_edw: product_id_edw (sku) of item that is replacing the returned item
        rma_exchange_item_product_id_shopify: product id in Shopify of the item that is replacing the returned item
        rma_exchange_item_variant_id_shopify: variant id in Shopify of the item that is replacing the returned item
        rma_exchange_item_title: display name of the item that is replacing the returned item
        rma_exchange_item_type: collection of the item that is replacing the returned item
        rma_exchange_item_quantity: quantity of items being sent to replace the returned item
        rma_exchange_item_currency: currency of exchange item values
        rma_exchange_item_product_value: value of item that is replacing the returned item
        rma_exchange_item_collection: collection of the item that is replacing the returned item per dim.product
        rma_exchange_item_family: family of the item that is replacing the returned item per dim.product
        rma_exchange_item_stage: stage of the item that is replacing the returned item per dim.product
        rma_exchange_item_merchandise_class: class of the item that is replacing the returned item per dim.product
        rma_exchange_item_upc_code: upc code of the item that is replacing the returned item per dim.product
        rma_exchange_item_design_tier: tier of the item that is replacing the returned item per dim.product
        rma_exchange_item_lens_sku: lens sku of the item that is replacing the returned item per dim.product
        rma_exchange_item_lens_type: lens type of the item that is replacing the returned item per dim.product
        rma_exchange_item_color_frame: frame color of the item that is replacing the returned item per dim.product
        rma_exchange_item_frame_artwork: frame artwork of the item that is replacing the returned item per dim.product
        rma_exchange_item_frame_finish: frame finish of the item that is replacing the returned item per dim.product
        rma_exchange_item_vendor_name: vendor of the item that is replacing the returned item per dim.product
 */
select
    rmas.aftership_id
    , rmas.rma_number
    , rmas.created_at::date as rma_created_date
    , rmas.customer_email as rma_email
    , rmas.original_order_id_edw
    , rmas.original_order_placed_at::date as original_order_date
    , case
        when
            exchange.rma_number is null
            and rmas.aftership_org not like '%warranty%'
        then
            'refund'
        when
            rmas.aftership_org like '%warranty%'
        then
            'warranty'
        when
            exchange.rma_number is not null
            and rmas.aftership_org not like '%warranty%'
        then
            'exchange'
        else
            'unknown rma type'
    end as rma_type
    , case
        when
            lower(rmas.return_method_name) like '%ship%'
        then
            'return'
        when
            lower(rmas.return_method_name) not like '%ship%'
        then
            'no return'
        else
            'unknown rma return type'
    end as rma_return_type
    , returns.return_item_product_id_edw as rma_item_product_id_edw
    , returns.return_item_product_id_shopify as rma_item_product_id_shopify
    , returns.return_item_variant_id_shopify as rma_item_variant_id_shopify
    , returns.return_item_title as rma_item_title
    , returns.return_item_type as rma_item_type
    , returns.return_item_reason as rma_item_reason
    , returns.return_item_subreason as rma_item_subreason
    , returns. return_item_reason_comment as rma_item_reason_comment
    , returns.ordered_quantity as original_ordered_item_quantity
    , returns.intended_return_quantity as rma_item_quantity
    , returns.return_item_total_price_currency as rma_item_currency
    , returns.return_item_total_price_amount - zeroifnull(returns.return_item_tax_price_amount) as rma_item_product_value
    , zeroifnull(returns.return_item_unit_discount_amount) as rma_item_discount_value
    , zeroifnull(returns.return_item_tax_price_amount) as rma_item_tax_value
    , return_product.collection as rma_item_collection
    , return_product.family as rma_item_family
    , return_product.stage as rma_item_stage
    , return_product.merchandise_class as rma_item_merchandise_class
    , return_product.upc_code as rma_item_upc_code
    , return_product.design_tier as rma_item_design_tier
    , return_product.lens_sku as rma_item_lens_sku
    , return_product.lens_type as rma_item_lens_type
    , return_product.color_frame as rma_item_color_frame
    , return_product.frame_artwork as rma_item_frame_artwork
    , return_product.finish_frame as rma_item_frame_finish
    , return_product.vendor_name as rma_item_vendor_name
    , exchange.exchange_item_product_id_edw as rma_exchange_item_product_id_edw
    , exchange.exchange_item_product_id_shopify as rma_exchange_item_product_id_shopify
    , exchange.exchange_item_variant_id_shopify as rma_exchange_item_variant_id_shopify
    , exchange_product.display_name as rma_exchange_item_title
    , case
        when
            exchange.exchange_item_product_id_edw is null
        then
            null
        when
            returns.return_item_product_id_edw != exchange.exchange_item_product_id_edw
            and lower(returns.return_item_title) != lower(exchange_product.display_name)
        then
            'different-item exchange'
        when
            returns.return_item_product_id_edw != exchange.exchange_item_product_id_edw
            and lower(returns.return_item_title) = lower(exchange_product.display_name)
        then
            'same-item different-sku exchange'
        when
            returns.return_item_product_id_edw = exchange.exchange_item_product_id_edw
        then
            'same-item same-sku exchange'
        else
            'other exchange'
    end as rma_exchange_item_type
    , exchange.exchange_quantity as rma_exchange_item_quantity
    , exchange.exchange_item_unit_price_currency as rma_exchange_item_currency
    , exchange.exchange_item_unit_price_amount as rma_exchange_item_product_value
    , exchange_product.collection as rma_exchange_item_collection
    , exchange_product.family as rma_exchange_item_family
    , exchange_product.stage as rma_exchange_item_stage
    , exchange_product.merchandise_class as rma_exchange_item_merchandise_class
    , exchange_product.upc_code as rma_exchange_item_upc_code
    , exchange_product.design_tier as rma_exchange_item_design_tier
    , exchange_product.lens_sku as rma_exchange_item_lens_sku
    , exchange_product.lens_type as rma_exchange_item_lens_type
    , exchange_product.color_frame as rma_exchange_item_color_frame
    , exchange_product.frame_artwork as rma_exchange_item_frame_artwork
    , exchange_product.finish_frame as rma_exchange_item_frame_finish
    , exchange_product.vendor_name as rma_exchange_item_vendor_name
from
    staging.aftership_rmas as rmas
left join
    staging.aftership_rmas_refund_return_items as returns
    on
        rmas.rma_number = returns.rma_number
left join
    staging.aftership_rmas_exchange_warranty_items as exchange
    on
        rmas.rma_number = exchange.rma_number
left join
    dim.product as return_product
    on
        returns.return_item_product_id_edw = return_product.product_id_edw
left join
    dim.product as exchange_product
    on
        exchange.exchange_item_product_id_edw = exchange_product.product_id_edw
where
    rmas.created_at >= '2025-01-21' --Aftership went live on Jan 21st, 2025
    and rmas.customer_email not like '%goodr.com' -- omit any orders from us because they are (likely) tests