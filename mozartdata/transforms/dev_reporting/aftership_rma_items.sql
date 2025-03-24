/*
    Table name:
        dev_reporting.aftership_rma_items
    Created:
        3-24-2025
    Purpose:
        Links fact.aftership_rma_items to dim.product to provide info on parts like lens, frame and vendor.
        each row contains the item returned and any items it was exchanged for, if any.
    Schema:
        aftership_id: The organization on Aftership
            Composite primary Key with rma_item_aftership_id
        rma_number: the main identifier for an Aftership customer request.
        rma_created_date: date rma was created
        rma_email: email of the customer that submitted the rma
        original_order_id_edw:  the order number of the original order that is associated with the RMA.
            Foreign key to fact.orders.order_id_edw and fact.aftership_rmas.original_order_id_edw
        original_order_date: date that the original order was placed
        rma_type: whether a item is part of a refund, an exchange or a warranty. NOT THE SAME AS fact.aftership_rmas
        rma_return_type: what type of return is the item - return or no return
        rma_item_aftership_id: id of the item being replaced from the original order. Is used to link the item being
            replaced with the item that is replacing it in the case of an exchange.
            Composite primary Key with aftership_id
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
    rma_items.id_aftership
  , rma_items.rma_number_aftership
  , rma_items.created_date
  , rma_items.customer_email
  , rma_items.original_order_id_edw
  , rma_items.original_order_date
  , rma_items.rma_type
  , rma_items.rma_return_type
  , rma_items.rma_item_aftership_id
  , rma_items.original_product_id_edw
  , rma_items.original_product_id_shopify
  , rma_items.original_variant_id_shopify
  , rma_items.rma_item_title
  , rma_items.rma_item_type
  , rma_items.rma_item_reason
  , rma_items.rma_item_subreason
  , rma_items.rma_item_reason_comment
  , rma_items.original_ordered_item_quantity
  , rma_items.rma_item_quantity
  , rma_items.rma_item_currency
  , rma_items.rma_item_product_value
  , rma_items.rma_item_discount_value
  , rma_items.rma_item_tax_value
  , return_product.collection          as rma_item_collection
  , return_product.family              as rma_item_family
  , return_product.stage               as rma_item_stage
  , return_product.merchandise_class   as rma_item_merchandise_class
  , return_product.upc_code            as rma_item_upc_code
  , return_product.design_tier         as rma_item_design_tier
  , return_product.lens_sku            as rma_item_lens_sku
  , return_product.lens_type           as rma_item_lens_type
  , return_product.color_frame         as rma_item_color_frame
  , return_product.frame_artwork       as rma_item_frame_artwork
  , return_product.finish_frame        as rma_item_frame_finish
  , return_product.vendor_name         as rma_item_vendor_name
  , rma_items.exchange_item_product_id_edw
  , rma_items.exchange_item_product_id_shopify
  , rma_items.exchange_item_variant_id_shopify
  , exchange_product.display_name      as exchange_item_title
  , case
        when
            rma_items.exchange_item_product_id_edw is null
            then
            null
        when
            rma_items.original_product_id_edw != rma_items.exchange_item_product_id_edw
                and lower(rma_items.rma_item_title) != lower(exchange_product.display_name)
            then
            'different-item exchange'
        when
            rma_items.original_product_id_edw != rma_items.exchange_item_product_id_edw
                and lower(rma_items.rma_item_title) = lower(exchange_product.display_name)
            then
            'same-item different-sku exchange'
        when
            rma_items.original_product_id_edw = rma_items.exchange_item_product_id_edw
            then
            'same-item same-sku exchange'
        else
            'other exchange'
    end                                as exchange_item_type
  , exchange_product.collection        as exchange_item_collection
  , exchange_product.family            as exchange_item_family
  , exchange_product.stage             as exchange_item_stage
  , exchange_product.merchandise_class as exchange_item_merchandise_class
  , exchange_product.upc_code          as exchange_item_upc_code
  , exchange_product.design_tier       as exchange_item_design_tier
  , exchange_product.lens_sku          as exchange_item_lens_sku
  , exchange_product.lens_type         as exchange_item_lens_type
  , exchange_product.color_frame       as exchange_item_color_frame
  , exchange_product.frame_artwork     as exchange_item_frame_artwork
  , exchange_product.finish_frame      as exchange_item_frame_finish
  , exchange_product.vendor_name       as exchange_item_vendor_name
  , rma_items.exchange_item_quantity
  , rma_items.exchange_item_currency
  , rma_items.exchange_item_product_value
from
    fact.aftership_rma_items as rma_items
    left join
        dim.product          as return_product
            on
            rma_items.original_product_id_edw = return_product.product_id_edw
    left join
        dim.product          as exchange_product
            on
            rma_items.exchange_item_product_id_edw = exchange_product.product_id_edw