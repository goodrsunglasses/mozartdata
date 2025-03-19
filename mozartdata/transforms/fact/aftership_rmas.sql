/*
    This table is used to display all the information regarding 
*/

select
    rmas.aftership_id
  , rmas.rma_number
  , rmas.created_at::date                                          as rma_created_date
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
            'unkown store'
    end                                                            as original_orer_channel
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
  , rmas.approved_at::date                                         as rma_approved_date
  , rmas.expired_at::date                                          as rma_expired_date
  , rmas.rejected_at::date                                         as rma_rejected_date
  , rmas.resolved_at::date                                         as rma_resolved_date
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
  , rmas.return_total_with_tax_currency                            as rma_currency
  , rmas.return_total_with_tax_amount -
    zeroifnull(rmas.return_tax_amount)                             as rma_total_product_value
  , zeroifnull(rmas.return_tax_amount)                             as rma_total_tax_value
  , rmas.est_refund_amount - (zeroifnull(rmas.return_tax_amount) -
                              zeroifnull(rmas.exchange_tax_total)) as rma_refund_product_value
  , zeroifnull(rmas.return_tax_amount) -
    zeroifnull(rmas.exchange_tax_total)                            as rma_refund_tax_value
  , rmas.refunded_at::date                                         as rma_refund_date
  , rmas.refund_destination                                        as rma_refund_destination
  , zeroifnull(rmas.exchange_total_incl_tax_amount) -
    zeroifnull(rmas.exchange_tax_total)                            as rma_exchange_product_value
  , zeroifnull(rmas.exchange_tax_total)                            as rma_exchange_tax_value
  , rmas.exchange_order_number                                     as rma_exchange_order_id_edw
  , rmas.checkout_upsell_currency                                  as rma_upsell_currency
  , rmas.checkout_upsell_total                                     as rma_upsell_total_value
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
    end                                                            as rma_return_status
  , rmas.shipment_slug                                             as rma_return_carrier
  , rmas.shipment_tracking_number                                  as rma_return_tracking_number
  , rmas.shipment_currency                                         as rma_return_currency
  , rmas.shipment_cost                                             as rma_return_cost
from
    staging.aftership_rmas as rmas
where
    rmas.created_at >= '2025-01-21' -- Aftership went live on Jan 21st, 2025.
    and lower(rmas.customer_email) not like '%goodr.com'