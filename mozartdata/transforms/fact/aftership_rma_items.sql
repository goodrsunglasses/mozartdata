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
        org_id_aftership: id of the aftership org as defined by the dwh team
            Composite Primary Key with rma_id_aftership and original_product_id_aftership
        org_name_aftership: name of the aftership org as defined in aftership itself
        rma_id_aftership: The id of the rma on Aftership
            Composite primary Key with org_id_aftership and original_product_id_aftership
        rma_number_aftership: the main identifier for an Aftership customer request.
        created_date: date rma was created
        customer_email: email of the customer that submitted the rma
        original_order_id_edw: the order number of the original order that is associated with the RMA.
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
        exchange_product_id_edw: product_id_edw (sku) of item that is replacing the returned item
        exchange_product_id_shopify: product id in Shopify of the item that is replacing the returned item
        exchange_variant_id_shopify	: variant id in Shopify of the item that is replacing the returned item
        quantity_exchanged: quantity of items being sent to replace the returned item
        exchange_currency: currency of exchange item values
        amount_product_exchanged: value of item that is replacing the returned item
        amount_total_rma: total amount being refunded and exchanged in the rma
 */
select
    orgs.org_id_aftership
  , orgs.org_name_aftership
  , rmas.rma_id_aftership
  , rmas.rma_number_aftership
  , rmas.created_at::date                                                                     as created_date
  , rmas.customer_email
  , rmas.original_order_id_edw
  , rmas.original_order_placed_at::date                                                       as original_order_date
  , case
        when
            exchange.rma_number_aftership is null
                and rmas.org_name_aftership not like '%warranty%'
            then
            'refund'
        when
            rmas.org_name_aftership like '%warranty%'
            then
            'warranty'
        when
            exchange.rma_number_aftership is not null
                and rmas.org_name_aftership not like '%warranty%'
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
  , returns.return_item_aftership_id                                                          as original_product_id_aftership
  , returns.return_item_product_id_edw                                                        as original_product_id_edw
  , returns.return_item_product_id_shopify                                                    as original_product_id_shopify
  , returns.return_item_variant_id_shopify                                                    as original_variant_id_shopify
  , returns.return_item_display_name                                                          as original_display_name
  , returns.return_item_type                                                                  as original_product_type
  , returns.return_item_reason                                                                as rma_product_reason
  , returns.return_item_subreason                                                             as rma_product_subreason
  , returns.return_item_reason_comment                                                        as rma_product_reason_comment
  , returns.ordered_quantity                                                                  as quantity_ordered
  , returns.intended_return_quantity                                                          as quantity_rma
  , returns.return_item_total_price_currency                                                  as currency
  , returns.return_item_total_price_amount - zeroifnull(returns.return_item_tax_price_amount) as amount_product_total
  , zeroifnull(returns.return_item_unit_discount_amount)                                      as amount_discount_total
  , zeroifnull(returns.return_item_tax_price_amount)                                          as amount_tax_total
  , exchange.exchange_item_product_id_edw                                                     as exchange_product_id_edw
  , exchange.exchange_item_product_id_shopify                                                 as exchange_product_id_shopify
  , exchange.exchange_item_variant_id_shopify                                                 as exchange_variant_id_shopify
  , exchange.exchange_quantity                                                                as quantity_exchanged
  , exchange.exchange_item_unit_price_currency                                                as exchange_currency
  , exchange.exchange_item_unit_price_amount                                                  as amount_product_exchanged
  , rmas.return_total_with_tax_amount                                                         as amount_total_rma
from
    staging.aftership_rmas                             as rmas
    inner join
        dim.aftership_orgs                             as orgs
            on rmas.org_id_aftership = orgs.org_id_aftership
    left join
        staging.aftership_rmas_refund_return_items     as returns
            on
            rmas.rma_number_aftership = returns.rma_number_aftership
    left join
        staging.aftership_rmas_exchange_warranty_items as exchange
            on
            rmas.rma_number_aftership = exchange.rma_number_aftership
                and returns.return_item_aftership_id = exchange.original_item_aftership_id
where
      rmas.created_at >= '2025-01-21' --Aftership went live on Jan 21st, 2025
  and rmas.customer_email not like '%goodr.com' -- omit any orders from us because they are (likely) tests