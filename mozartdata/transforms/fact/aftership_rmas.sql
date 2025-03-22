/*
    Table name: fact.aftership_rmas
    Created: 3-14-2025
    Purpose: takes information from staging.aftership_rmas and turns them into more usable columns. That means it
        takes certain columns and groups them to reinterpret what they mean.

    Schema:
        aftership_id: The organization on Aftership
        rma_number: the main identifier for an Aftership customer request.
            Primary Key
        rma_created_date: date rma was created
        rma_email: email of the customer that submitted the rma
        original_order_id_edw:  the order number of the original order that is associated with the RMA.
            Foreign key to fact.orders.order_id_edw and fact.aftership_rma_items.original_order_id_edw
        original_order_id_shopify: id as it is shows in the address bar when viewing it on the shopify website
        original_order_date: date that the original order was placed
        original_order_channel: original channel order was placed on. Matches dim.channel or is "unknown source"
        rma_status: status of rma, simplified from the various values from aftership. can be completed, cancelled,
            incomplete or other
        rma_approved_date: date rma was approved
        rma_expired_date: date rma expired
        rma_rejected_date: date rma was rejected
        rma_resolved_date: date rma was resolved, as in it no longer needed any further action
        rma_type: whether an rma was an upsell, downsell, refund or exchange
        rma_currency: currency of product and tax values
        rma_total_product_value: total product value of the products in the rma as originally sold
        rma_total_tax_value: value of tax was on all rma products when originally sold
        rma_refund_product_value: value of refunds on products in rma (as opposed to any exchanges in the rma)
        rma_refund_tax_value: value of tax on refunds in this rma
        rma_refund_date: date refund was issued
        rma_refund_destination: destination of refund, empty if no refund destination
        rma_exchange_product_value: value of products exchanged in this rma (as opposed to returned or refunded)
        rma_exchange_tax_value: value of tax on exchanges in rma
        rma_exchange_order_id_edw: order number on Shopify of exchange order, if any.
            Foreign key to fact.orders.order_id_edw and fact.aftership_rma_items.original_order_id_edw
        rma_upsell_currency: currency of any upsell values in rma
        rma_upsell_total_value: total value of upsells in this rma, including tax
        rma_return_type: type of return, can be 'no return' or 'return'
        rma_return_status: status of return, inidcating if a reurn has been shipped, is in transit, or is received.
        rma_return_carrier: carrier of the return, e.g. usps
        rma_return_tracking_number: tracking number of return, is null until slug receives package. Likely connects
            to fulfillment tables but not sure how at this time.
            todo: add boolean in relevant fulfillment table
        rma_return_currency: currency of return cost
        rma_return_cost: cost of shipping return
*/

select
    rmas.aftership_id
  , rmas.rma_number
  , rmas.created_at::date                                          as created_date
  , rmas.customer_email                                            as rma_email
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
    end                                                            as rma_status
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
        when
            aftership_org like '%returns%'
            then
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
        else
            'unknown organization'
    end                                                            as rma_type
  , rmas.return_total_with_tax_currency                            as currency
  , rmas.return_total_with_tax_amount -
    zeroifnull(rmas.return_tax_amount)                             as amount_product_total
  , zeroifnull(rmas.return_tax_amount)                             as amount_tax_total
  , rmas.refund_destination                                        as refund_payment_destination
  , rmas.est_refund_amount - (zeroifnull(rmas.return_tax_amount) -
                              zeroifnull(rmas.exchange_tax_total)) as amount_product_refunded
  , zeroifnull(rmas.return_tax_amount) -
    zeroifnull(rmas.exchange_tax_total)                            as amount_tax_refunded
  , zeroifnull(rmas.exchange_total_incl_tax_amount) -
    zeroifnull(rmas.exchange_tax_total)                            as amount_product_exchanged
  , zeroifnull(rmas.exchange_tax_total)                            as amount_tax_exchanged
  , rmas.exchange_order_number                                     as exchange_order_id_edw
  , rmas.checkout_upsell_currency                                  as upsell_currency
  , rmas.checkout_upsell_total                                     as amount_total_upsell
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
