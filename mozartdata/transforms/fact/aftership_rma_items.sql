/*
    Table name:
        fact.aftership_rma_items
    Created:
        3-14-2025
    Purpose:
        Takes information from staging.aftership_rmas_refund_return_items and
        aftership_rmas_exchange_warranty_items and creates a table for determining item-level info in rmas, e.g. sku,
        quantity and value.

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
        rma_exchange_item_product_id_edw: product_id_edw (sku) of item that is replacing the returned item
        rma_exchange_item_product_id_shopify: product id in Shopify of the item that is replacing the returned item
        rma_exchange_item_variant_id_shopify: variant id in Shopify of the item that is replacing the returned item
        rma_exchange_item_quantity: quantity of items being sent to replace the returned item
        rma_exchange_item_currency: currency of exchange item values
        rma_exchange_item_product_value: value of item that is replacing the returned item
 */
select
    rmas.id_aftership
  , rmas.rma_number                                                                           as rma_number_aftership
  , rmas.created_at::date                                                                     as created_date
  , rmas.customer_email
  , rmas.original_order_id_edw
  , rmas.original_order_placed_at::date                                                       as original_order_date
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
    end                                                                                       as rma_type
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
    end                                                                                       as rma_return_type
  , returns.return_item_aftership_id                                                          as rma_item_aftership_id
  , returns.return_item_product_id_edw                                                        as original_product_id_edw
  , returns.return_item_product_id_shopify                                                    as original_product_id_shopify
  , returns.return_item_variant_id_shopify                                                    as original_variant_id_shopify
  , returns.return_item_title                                                                 as rma_item_title
  , returns.return_item_type                                                                  as rma_item_type
  , returns.return_item_reason                                                                as rma_item_reason
  , returns.return_item_subreason                                                             as rma_item_subreason
  , returns.return_item_reason_comment                                                        as rma_item_reason_comment
  , returns.ordered_quantity                                                                  as original_ordered_item_quantity
  , returns.intended_return_quantity                                                          as rma_item_quantity
  , returns.return_item_total_price_currency                                                  as rma_item_currency
  , returns.return_item_total_price_amount - zeroifnull(returns.return_item_tax_price_amount) as rma_item_product_value
  , zeroifnull(returns.return_item_unit_discount_amount)                                      as rma_item_discount_value
  , zeroifnull(returns.return_item_tax_price_amount)                                          as rma_item_tax_value
  , exchange.exchange_item_product_id_edw                                                     as exchange_item_product_id_edw
  , exchange.exchange_item_product_id_shopify                                                 as exchange_item_product_id_shopify
  , exchange.exchange_item_variant_id_shopify                                                 as exchange_item_variant_id_shopify
  , exchange.exchange_quantity                                                                as exchange_item_quantity
  , exchange.exchange_item_unit_price_currency                                                as exchange_item_currency
  , exchange.exchange_item_unit_price_amount                                                  as exchange_item_product_value
from
    staging.aftership_rmas                             as rmas
    left join
        staging.aftership_rmas_refund_return_items     as returns
            on
            rmas.rma_number = returns.rma_number
    left join
        staging.aftership_rmas_exchange_warranty_items as exchange
            on
            rmas.rma_number = exchange.rma_number
                and returns.return_item_aftership_id = exchange.original_item_aftership_id
where
      rmas.created_at >= '2025-01-21' --Aftership went live on Jan 21st, 2025
  and rmas.customer_email not like '%goodr.com' -- omit any orders from us because they are (likely) tests
