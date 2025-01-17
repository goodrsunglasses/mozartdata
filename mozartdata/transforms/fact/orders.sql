with
    refund_aggregates as (
        select distinct
            order_id_edw
            , first_value(transaction_created_timestamp_pst) over (
                partition by
                    order_id_edw
                order by
                    transaction_created_timestamp_pst asc
            ) as refund_timestamp_pst
        from
             fact.refund
    )
select
    o.order_id_edw
    , o.order_id_ns
    , o.channel
    , o.customer_id_ns
    , o.customer_id_edw
    , o.tier
    , o.location
    , o.warranty_order_id_ns
    , o.booked_date
    , o.booked_date_shopify
    , o.booked_date_ns
    , o.sold_date
    , o.fulfillment_date
    , o.fulfillment_date_ns
    , o.shipping_window_start_date
    , o.shipping_window_end_date
    , o.is_exchange
    , o.status_flag_edw
    , o.b2b_d2c
    , o.model
    , o.quantity_booked
    , o.quantity_booked_shopify
    , o.quantity_booked_ns
    , o.quantity_sold_shopify
    , o.quantity_sold_ns
    , o.quantity_sold
    , o.quantity_fulfilled
    , o.quantity_fulfilled_stord
    , o.quantity_fulfilled_shipstation
    , o.quantity_fulfilled_ns
    , o.quantity_refunded
    , o.quantity_refunded_ns
    , o.rate_booked
    , o.rate_booked_ns
    , o.rate_sold
    , o.rate_refunded
    , o.rate_refunded_ns
    , o.amount_revenue_booked_shopify
    , o.amount_revenue_booked_ns
    , o.amount_revenue_booked
    , o.amount_revenue_booked_shopify_cad
    , o.amount_product_booked_shopify
    , o.amount_product_booked_ns
    , o.amount_product_booked
    , o.amount_discount_booked_shopify
    , o.amount_discount_booked_ns
    , o.amount_discount_booked
    , o.amount_tax_booked_shopify
    , o.amount_tax_booked_ns
    , o.amount_tax_booked
    , o.amount_shipping_booked_shopify
    , o.amount_shipping_booked_ns
    , o.amount_shipping_booked
    , o.amount_paid_booked_shopify
    , o.amount_paid_booked_ns
    , o.amount_paid_booked
    , o.amount_revenue_sold
    , o.amount_product_sold
    , o.amount_discount_sold
    , o.amount_shipping_sold
    , o.amount_tax_sold
    , o.amount_paid_sold
    , o.amount_cogs_fulfilled
    , o.amount_revenue_refunded
    , o.amount_product_refunded
    , o.amount_shipping_refunded
    , o.amount_tax_refunded
    , o.amount_paid_refunded
    , o.revenue
    , o.amount_paid_total
    , o.gross_profit_estimate
    , o.cost_estimate
    ,case
        when refund.order_id_edw is not null
        then true
        else false
    end                          as has_refund
    , refund.refund_timestamp_pst
    , date(refund.refund_timestamp_pst)                                                  as refund_date_pst
from
    bridge.orders as o
left outer join
    refund_aggregates               refund
    on
        refund.order_id_edw = o.order_id_edw