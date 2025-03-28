/*
    Table name:
        dev_reporting.aftership_rma_items
    Created:
        3-24-2025
    Purpose:
        Links fact.aftership_rma_items to dim.product to provide info on parts like lens, frame and vendor.
        each row contains the item returned and any items it was exchanged for, if any.
    Schema:

        org_id_aftership: id of the aftership org as defined by the dwh team
            Composite Primary Key with rma_id_aftership and original_product_id_aftership
        org_name_aftership: name of the aftership org as defined in aftership itself
        rma_id_aftership: The id of the rma on Aftership
            Composite primary Key with org_id_aftership and original_product_id_aftership
        rma_number_aftership: the main identifier for an Aftership customer request.
        created_date: date rma was created
        customer_email: email of the customer that submitted the rma
        original_order_id_edw:  the order number of the original order that is associated with the RMA.
            Foreign key to fact.orders.order_id_edw and fact.aftership_rmas.original_order_id_edw
        original_order_date: date that the original order was placed
        rma_type: whether a item is part of a refund, an exchange or a warranty. NOT THE SAME AS fact.aftership_rmas
        rma_return_type: what type of return is the item - return or no return
        original_product_id_aftership: id of the item being replaced from the original order. Is used to link the item being
            replaced with the item that is replacing it in the case of an exchange.
            Composite primary Key with org_id_aftership and rma_id_aftership
        original_product_id_edw: product_id_edw (sku) of the item
        original_product_id_shopify: product id in Shopify of the item
        original_variant_id_shopify: variant id in Shopify of the item
        original_display_name: display name of item
        original_product_type: collection of item, e.g. the OGs
        rma_product_reason: reason item is being returned
        rma_product_subreason: subreason item is being returned
        rma_product_reason_comment: comment on item being returned. Contains date code
        quantity_ordered: original ordered item quantity
        quantity_rma: quantity being subitted in the rma
        currency: currency of item values
        amount_product_total: value of product in original order, MAY NOT HAVE BEEN WHAT WAS CHARGED
        amount_discount_total: value of discount on item in original order, MAY NOT HAVE BEEN ITEM LEVEL IN
            ORIGINAL ORDER
        amount_tax_total: value of tax on item in the original order
        original_item_collection: collection of item per dim.product
        original_item_family: family of item per dim.product
        original_item_stage: stage of item per dim.product
        original_item_merchandise_class: class of item per dim.product
        original_item_upc_code: upc code of item per dim.product
        original_item_design_tier: design tier of item per dim.product
        original_item_lens_sku: lens sku per dim.product
        original_item_lens_type: lens type per dim.product
        original_item_color_lens_base: lens color base per dim.product
        original_item_color_lens_finish: lens color finish per dim.product
        original_item_color_frame: frame color per dim.product
        original_item_frame_artwork: frame artwork per dim.product
        original_item_frame_finish: frame finish per dim.product
        original_item_vendor_name: vendor per dim.product
        exchange_product_id_edw: product_id_edw (sku) of item that is replacing the returned item
        exchange_product_id_shopify: product id in Shopify of the item that is replacing the returned item
        exchange_variant_id_shopify: variant id in Shopify of the item that is replacing the returned item
        exchange_product_display_name: display name of the item that is replacing the returned item
        exchange_item_type: collection of the item that is replacing the returned item
        quantity_exchanged: quantity of items being sent to replace the returned item
        exchange_currency: currency of exchange item values
        amount_product_exchanged: value of item that is replacing the returned item
        exchange_product_collection: collection of the item that is replacing the returned item per dim.product
        exchange_product_family: family of the item that is replacing the returned item per dim.product
        exchange_product_stage: stage of the item that is replacing the returned item per dim.product
        exchange_product_merchandise_class: class of the item that is replacing the returned item per dim.product
        exchange_product_upc_code: upc code of the item that is replacing the returned item per dim.product
        exchange_product_design_tier: tier of the item that is replacing the returned item per dim.product
        exchange_product_lens_sku: lens sku of the item that is replacing the returned item per dim.product
        exchange_product_lens_type: lens type of the item that is replacing the returned item per dim.product
        exchange_product_color_lens_base: lens color base of the item that is replacing the returned item per dim.product
        exchange_product_color_lens_base: lens color finish of the item that is replacing the returned item per dim.product
        exchange_product_color_frame: frame color of the item that is replacing the returned item per dim.product
        exchange_product_frame_artwork: frame artwork of the item that is replacing the returned item per dim.product
        exchange_product_frame_finish: frame finish of the item that is replacing the returned item per dim.product
        exchange_product_vendor_name: vendor of the item that is replacing the returned item per dim.product
 */
select
    rma_items.org_id_aftership
  , rma_items.org_name_aftership
  , rma_items.rma_id_aftership
  , rma_items.rma_number_aftership
  , rma_items.created_date
  , rma_items.customer_email
  , rma_items.original_order_id_edw
  , rma_items.original_order_date
  , rma_items.rma_type
  , rma_items.rma_return_type
  , rma_items.original_product_id_aftership
  , rma_items.original_product_id_edw
  , rma_items.original_product_id_shopify
  , rma_items.original_variant_id_shopify
  , rma_items.original_display_name
  , rma_items.original_product_type
  , rma_items.rma_product_reason
  , rma_items.rma_product_subreason
  , rma_items.rma_product_reason_comment
  , rma_items.quantity_ordered
  , rma_items.quantity_rma
  , rma_items.currency
  , rma_items.amount_product_total
  , rma_items.amount_discount_total
  , rma_items.amount_tax_total
  , return_product.collection          as original_item_collection
  , return_product.family              as original_item_family
  , return_product.stage               as original_item_stage
  , return_product.merchandise_class   as original_item_merchandise_class
  , return_product.upc_code            as original_item_upc_code
  , return_product.design_tier         as original_item_design_tier
  , return_product.lens_sku            as original_item_lens_sku
  , return_product.lens_type           as original_item_lens_type
  , return_product.color_lens_base     as original_item_color_lens_base
  , return_product.color_lens_finish   as original_item_color_lens_finish
  , return_product.color_frame         as original_item_color_frame
  , return_product.frame_artwork       as original_item_frame_artwork
  , return_product.finish_frame        as original_item_frame_finish
  , return_product.vendor_name         as original_item_vendor_name
  , rma_items.exchange_product_id_edw
  , rma_items.exchange_product_id_shopify
  , rma_items.exchange_variant_id_shopify
  , exchange_product.display_name      as exchange_product_display_name
  , case
        when
            rma_items.exchange_product_id_edw is null
            then
            null
        when
            rma_items.original_product_id_edw != rma_items.exchange_product_id_edw
                and lower(rma_items.original_display_name) != lower(exchange_product.display_name)
            then
            'different-item exchange'
        when
            rma_items.original_product_id_edw != rma_items.exchange_product_id_edw
                and lower(rma_items.original_display_name) = lower(exchange_product.display_name)
            then
            'same-item different-sku exchange'
        when
            rma_items.original_product_id_edw = rma_items.exchange_product_id_edw
            then
            'same-item same-sku exchange'
        else
            'other exchange'
    end                                as exchange_item_type
  , rma_items.quantity_exchanged
  , rma_items.exchange_currency
  , rma_items.amount_product_exchanged
  , rma_items.amount_total_rma
  , exchange_product.collection        as exchange_product_collection
  , exchange_product.family            as exchange_product_family
  , exchange_product.stage             as exchange_product_stage
  , exchange_product.merchandise_class as exchange_product_merchandise_class
  , exchange_product.upc_code          as exchange_product_upc_code
  , exchange_product.design_tier       as exchange_product_design_tier
  , exchange_product.lens_sku          as exchange_product_lens_sku
  , exchange_product.lens_type         as exchange_product_lens_type
  , exchange_product.color_lens_base   as exchange_product_color_lens_base
  , exchange_product.color_lens_finish as exchange_product_color_lens_finish
  , exchange_product.color_frame       as exchange_product_color_frame
  , exchange_product.frame_artwork     as exchange_product_frame_artwork
  , exchange_product.finish_frame      as exchange_product_frame_finish
  , exchange_product.vendor_name       as exchange_product_vendor_name
from
    fact.aftership_rma_items as rma_items
    left join
        dim.product          as return_product
            on
            rma_items.original_product_id_edw = return_product.product_id_edw
    left join
        dim.product          as exchange_product
            on
            rma_items.exchange_product_id_edw = exchange_product.product_id_edw