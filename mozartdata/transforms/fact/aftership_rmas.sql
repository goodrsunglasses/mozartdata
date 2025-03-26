/*
    Table name:
        fact.aftership_rmas
    Created:
        3-14-2025
    Purpose:
        takes information from staging.aftership_rmas and turns them into more usable columns. That means it
        takes certain columns and groups them to reinterpret what they mean.
    Schema:
        rma_id_aftership: The id of the rma on Aftership
            Primary Key
        rma_number_aftership: the main identifier for an Aftership customer request.
        created_date: date rma was created
        customer_email: email of the customer that submitted the rma
        original_order_id_edw: the order number of the original order that is associated with the RMA.
            Foreign key to fact.orders.order_id_edw and fact.aftership_rma_items.original_order_id_edw
        original_order_id_shopify: id as it is shows in the address bar when viewing it on the shopify website
        original_order_date: date that the original order was placed
        original_order_channel: original channel order was placed on. Matches dim.channel or is "unknown source"
        rma_completion_status: status of rma, simplified from the various values from aftership. can be completed, cancelled,
            incomplete or other
        ema_approval_status: status of rma as shown on Aftership
        approved_date: date rma was approved
        expired_date: date rma expired
        rejected_date: date rma was rejected
        refund_date: date refund was issued
        resolved_date: date rma was resolved, as in it no longer needed any further action
        rma_type: whether an rma was an upsell, downsell, refund or exchange
        currency: currency of product and tax values
        amount_product_total: total product value of the products in the rma as originally sold
        amount_tax_total: value of tax was on all rma products when originally sold
        refund_payment_destination: destination of refund, empty if no refund destination
        amount_product_refund: value of refunds on products in rma (as opposed to any exchanges in the rma)
        amount_tax_refund: value of tax on refunds in this rma
        amount_total_refund: total amount refunded to the customer
        amount_product_exchange: value of products exchanged in this rma (as opposed to returned or refunded)
        amount_tax_exchange: value of tax on exchanges in rma
        amount_total_exchange: total value of the exchange
        amount_total_rma: total value of this rma in total, with refunds and exchanges
        exchange_order_id_edw: order number on Shopify of exchange order, if any.
            Foreign key to fact.orders.order_id_edw and fact.aftership_rma_items.original_order_id_edw
        upsell_currency: currency of any upsell values in rma
        amount_upsell_total	: total value of upsells in this rma, including tax
        rma_return_type: type of return, can be 'no return' or 'return'
        return_status: status of return, inidcating if a reurn has been shipped, is in transit, or is received.
        return_carrier: carrier of the return, e.g. usps
        return_tracking_number: tracking number of return, is null until slug receives package. Likely connects
            to fulfillment tables but not sure how at this time.
            todo: add boolean in relevant fulfillment table
        return_currency: currency of return cost
        amount_shipping_return: cost of shipping return
*/

select
    rmas.rma_id_aftership
  , rmas.rma_number_aftership
  , rmas.created_at::date                                          as created_date
  , rmas.customer_email
  , rmas.original_order_id_edw
  , rmas.original_order_id_shopify
  , rmas.original_order_placed_at::date                            as original_order_date
  , case
        when
            lower(rmas.original_order_store) = 'goodr-sunglasses'
            then
            'Goodr.com'
        when
            lower(rmas.original_order_store) = 'goodr-canada-d2c'
            then
            'goodr.ca'
        else
            'unknown store'
    end                                                            as original_order_channel
  , case
        when
            rmas.approval_status = 'done'
            then
            'complete'
        when
            rmas.approval_status = 'expired'
                or rmas.approval_status = 'rejected'
            then
            'cancelled'
        when
            rmas.approval_status = 'submitted'
                or rmas.approval_status = 'approved'
            then
            'incomplete'
        else
            'other'
    end                                                            as rma_completion_status
  , rmas.approval_status                                           as rma_approval_status
  , rmas.approved_at::date                                         as approved_date
  , rmas.expired_at::date                                          as expired_date
  , rmas.rejected_at::date                                         as rejected_date
  , rmas.refunded_at::date                                         as refund_date
  , rmas.resolved_at::date                                         as resolved_date
  , case
        when
            aftership_org like '%warranty'
            then
            'warranty'
        else
            case
                when
                    checkout_upsell_total != 0
                    then
                    'upsell'
                when
                    exchange_total_incl_tax_amount is null
                        and checkout_upsell_total = 0
                    then
                    'refund'
                when
                    exchange_total_incl_tax_amount is not null
                        and est_refund_amount = 0
                        and checkout_upsell_total = 0
                    then
                    'exchange'
                when
                    exchange_total_incl_tax_amount is not null
                        and est_refund_amount != 0
                        and checkout_upsell_total = 0
                    then
                    'downsell'
                else
                    'unknown rma type'
            end
    end                                                            as rma_type
  , rmas.return_total_with_tax_currency                            as currency
  , rmas.return_total_with_tax_amount -
    zeroifnull(rmas.return_tax_amount)                             as amount_product_total
  , zeroifnull(rmas.return_tax_amount)                             as amount_tax_total
  , rmas.refund_destination                                        as refund_payment_destination
  , rmas.est_refund_amount - (zeroifnull(rmas.return_tax_amount) -
                              zeroifnull(rmas.exchange_tax_total)) as amount_product_refund
  , zeroifnull(rmas.return_tax_amount) -
    zeroifnull(rmas.exchange_tax_total)                            as amount_tax_refund
  , rmas.est_refund_amount                                         as amount_total_refund
  , zeroifnull(rmas.exchange_total_incl_tax_amount) -
    zeroifnull(rmas.exchange_tax_total)                            as amount_product_exchange
  , zeroifnull(rmas.exchange_tax_total)                            as amount_tax_exchange
  , zeroifnull(rmas.exchange_total_incl_tax_amount)                as amount_total_exchange
  , rmas.return_total_with_tax_amount                              as amount_total_rma
  , rmas.exchange_order_number                                     as exchange_order_id_edw
  , rmas.checkout_upsell_currency                                  as upsell_currency
  , rmas.checkout_upsell_total                                     as amount_upsell_total
  , case
        when
            lower(rmas.return_method_name) like '%ship%'
            then
            'return required'
        else
            'no return'
    end                                                            as rma_return_type
  , case
        when
            lower(rmas.return_method_name) not like '%ship%'
            then
            null
        when
            lower(rmas.return_method_name) like '%ship%'
                and rmas.return_received_at is not null
            then
            'return received'
        when
            lower(rmas.return_method_name) like '%ship%'
                and rmas.return_received_at is null
                and rmas.shipment_slug is not null
            then
            'return in transit'
        when
            lower(rmas.return_method_name) like '%ship%'
                and rmas.return_received_at is null
                and rmas.shipment_slug is null
            then
            'return not shipped'
        else
            'return status unknown'
    end                                                            as return_status
  , rmas.shipment_slug                                             as return_carrier
  , rmas.shipment_tracking_number                                  as return_tracking_number
  , rmas.shipment_currency                                         as return_currency
  , rmas.shipment_cost                                             as amount_shipping_return
from
    staging.aftership_rmas as rmas
where
      rmas.created_at >= '2025-01-21' -- Aftership went live on Jan 21st, 2025.
  and lower(rmas.customer_email) not like '%goodr.com'