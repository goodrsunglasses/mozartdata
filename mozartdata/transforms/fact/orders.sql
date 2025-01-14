/*--first grab the netsuite info from dim.orders which implicitly should only
  have parent transactions from NS.
 */
with
    shopify_info as ( --Grab any and all shopify info from this CTE
        select
            orders.order_id_edw
            , shopify.amount_booked                                                            as amount_product_booked_shop
            , shopify.shipping_sold                                                            as amount_shipping_booked_shop
            , shopify.amount_tax_sold                                                          as amount_tax_booked_shop
            , shopify.amount_standard_discount                                                 as amount_discount_booked_shop
            , shopify.amount_booked + shopify.shipping_sold -
                shopify.amount_standard_discount                                                 as amount_revenue_booked_shop
            , shopify.amount_booked + shopify.shipping_sold + shopify.amount_tax_sold -
                shopify.amount_total_discount                                                    as amount_paid_booked_shop
            , shopify.order_created_date_pst
            , shopify.quantity_booked                                                          as quantity_booked_shopify
            , shopify.quantity_sold                                                            as quantity_sold_shopify
        from
            dim.orders                          orders
        left outer join
            fact.shopify_orders shopify
            on
                shopify.order_id_shopify = orders.order_id_shopify
    )
    , fulfillment_info as ( --Grab any and all shopify info from this CTE
        select
             orders.order_id_edw
            , sum(quantity_ns)    as total_quantity_ns
            , sum(quantity_stord) as total_quantity_stord
            , sum(quantity_ss)    as total_quantity_ss
        from
            dim.orders                            orders
        left outer join
            dim.fulfillment       fulfill
            on
                fulfill.order_id_edw = orders.order_id_edw
        left outer join
            fact.fulfillment_item fulfill_item
            on
                fulfill_item.fulfillment_id_edw = fulfill.fulfillment_id_edw
        group by
            orders.order_id_edw
    )
    , aggregates as (
        select
            oi.order_id_edw
            , sum(
                case
                    when oi.plain_name not in ('Tax', 'Shipping')
                    then oi.quantity_booked
                    else 0
                end
            )                                      as quantity_booked
            , sum(
                case
                    when oi.plain_name not in ('Tax', 'Shipping')
                    then oi.quantity_sold
                    else 0
                end
            )                                      as quantity_sold
            , sum(
                case
                    when oi.plain_name not in ('Tax', 'Shipping')
                    then oi.quantity_fulfilled
                    else 0
                end
            )                                  as quantity_fulfilled
            , sum(
                case
                    when oi.plain_name not in ('Tax', 'Shipping')
                    then oi.quantity_refunded
                    else 0
                end
            )                                  as quantity_refunded
            , sum(
                case
                    when oi.plain_name not in ('Tax', 'Shipping')
                    then oi.rate_booked
                    else 0
                end
            )                                  as rate_booked
            , sum(
                case
                    when oi.plain_name not in ('Tax', 'Shipping')
                    then oi.rate_sold
                    else 0
                end
            )                                  as rate_sold
            , sum(
                case
                    when oi.plain_name not in ('Tax', 'Shipping')
                    then oi.rate_refunded
                    else 0
                end
            )                                  as rate_refunded
            , sum(oi.amount_revenue_booked)    as amount_revenue_booked
            , sum(oi.amount_product_booked)    as amount_product_booked
            , sum(oi.amount_discount_booked)   as amount_discount_booked
            , sum(oi.amount_shipping_booked)   as amount_shipping_booked
            , sum(oi.amount_tax_booked)        as amount_tax_booked
            , sum(oi.amount_paid_booked)       as amount_paid_booked
            , sum(oi.amount_revenue_sold)      as amount_revenue_sold
            , sum(oi.amount_product_sold)      as amount_product_sold
            , sum(oi.amount_discount_sold)     as amount_discount_sold
            , sum(oi.amount_shipping_sold)     as amount_shipping_sold
            , sum(oi.amount_tax_sold)          as amount_tax_sold
            , sum(oi.amount_paid_sold)         as amount_paid_sold
            , sum(oi.amount_cogs_fulfilled)    as amount_cogs_fulfilled
            , sum(oi.amount_revenue_refunded)  as amount_revenue_refunded
            , sum(oi.amount_product_refunded)  as amount_product_refunded
            , sum(oi.amount_shipping_refunded) as amount_shipping_refunded
            , sum(oi.amount_tax_refunded)      as amount_tax_refunded
            , sum(oi.amount_paid_refunded)     as amount_paid_refunded
            , sum(oi.revenue)                  as revenue
            , sum(oi.amount_paid_total)        as amount_paid_total
            , sum(
                case
                    when oi.plain_name not in ('Tax', 'Shipping')
                    then oi.gross_profit_estimate
                    else 0
                end
            )                                  as gross_profit_estimate
            , sum(
                case
                    when oi.plain_name not in ('Tax', 'Shipping')
                    then oi.cost_estimate
                    else 0
                end
            )                                   as cost_estimate
        from
            fact.order_item oi
        group by
            order_id_edw
    )
    , refund_aggregates as (
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
    orders.order_id_edw
    , orders.order_id_ns
    , aggregate_netsuite.channel
    , aggregate_netsuite.customer_id_ns
    , aggregate_netsuite.customer_id_edw
    , aggregate_netsuite.tier
    , location.name                                                               as location
    , aggregate_netsuite.warranty_order_id_ns
    , coalesce(
        --shopify shows first as it is considered the "booking" source of truth
        shopify_info.order_created_date_pst
        , aggregate_netsuite.booked_date
    )                                             as booked_date
    , shopify_info.order_created_date_pst                                         as booked_date_shopify
    , aggregate_netsuite.booked_date                                              as booked_date_ns
    , aggregate_netsuite.sold_date
     --placeholders for rn for when we ad a fulfillment source of truth
    , aggregate_netsuite.fulfillment_date                                         as fulfillment_date
    , aggregate_netsuite.fulfillment_date                                         as fulfillment_date_ns
    , aggregate_netsuite.shipping_window_start_date
    , aggregate_netsuite.shipping_window_end_date
    , aggregate_netsuite.is_exchange
    , aggregate_netsuite.status_flag_edw
    , case when refund.order_id_edw is not null then true else false end          as has_refund
    , refund_timestamp_pst
    , date(refund_timestamp_pst)                                                  as refund_date_pst
    , b2b_d2c
    , aggregate_netsuite.model
    , coalesce(shopify_info.quantity_booked_shopify, aggregates.quantity_booked)  as quantity_booked-- source of truth column for quantities also comes from shopify
    , shopify_info.quantity_booked_shopify                                        as quantity_booked_shopify
    , aggregates.quantity_booked                                                  as quantity_booked_ns
    , shopify_info.quantity_sold_shopify                                          as quantity_sold_shopify
    , aggregates.quantity_sold                                                    as quantity_sold_ns
    , aggregates.quantity_sold
    , case
        when aggregate_netsuite.channel not in (
            'Key Account'
            , 'Key Accounts'
            , 'Global'
            , 'Prescription'
            , 'Key Account CAN'
            , 'Amazon Canada'
            , 'Amazon Prime'
            , 'Cabana'
            , 'Amazon'
        )
        then (
            coalesce(
                fulfillment_info.total_quantity_stord
                , 0
            ) + coalesce(
                fulfillment_info.total_quantity_ss
                , 0
            )
        )
        else aggregates.quantity_fulfilled
    end                                                                           as quantity_fulfilled--As per notes from our meeting, the idea is that on orders not in the channels, we dont want this column to show Netsuite IF information if its lacking from Stord/SS
    , fulfillment_info.total_quantity_stord                                       as quantity_fulfilled_stord
    , fulfillment_info.total_quantity_ss                                          as quantity_fulfilled_shipstation
    , fulfillment_info.total_quantity_ns                                          as quantity_fulfilled_ns
    , aggregates.quantity_refunded
    , aggregates.quantity_refunded                                                as quantity_refunded_ns
    , aggregates.rate_booked
    , aggregates.rate_booked                                                      as rate_booked_ns
    , aggregates.rate_sold
    , aggregates.rate_refunded
    , aggregates.rate_refunded                                                    as rate_refunded_ns
    --shopify is also the source of truth for booking financial amount (SO's shouldnt matter GL wise anyways)
    --converting shopify info from CAD to USD
    --This sounds odd but it makes sense as shopify considers this "sold" but ns _sold is used to denote invoices and cash sales
    , case
        when aggregate_netsuite.channel_currency_abbreviation = 'CAD'
        then shopify_info.amount_revenue_booked_shop * cer.exchange_rate
        else shopify_info.amount_revenue_booked_shop
    end                                                                           as amount_revenue_booked_shopify
    , aggregates.amount_revenue_booked                                            as amount_revenue_booked_ns
    , coalesce(amount_revenue_booked_shopify, amount_revenue_booked_ns)           as amount_revenue_booked
    , case
        when aggregate_netsuite.channel_currency_abbreviation = 'CAD'
        then shopify_info.amount_revenue_booked_shop
    end                                                                           as amount_revenue_booked_shopify_cad --this column shows the original CAD version of revenue, if applicable
    , case
        when aggregate_netsuite.channel_currency_abbreviation = 'CAD'
        then shopify_info.amount_product_booked_shop * cer.exchange_rate
        else shopify_info.amount_product_booked_shop
    end                                                                           as amount_product_booked_shopify
    , aggregates.amount_product_booked                                            as amount_product_booked_ns
    , coalesce(amount_product_booked_shopify, amount_product_booked_ns)           as amount_product_booked
    , case
        when aggregate_netsuite.channel_currency_abbreviation = 'CAD'
        then shopify_info.amount_discount_booked_shop * cer.exchange_rate
        else shopify_info.amount_discount_booked_shop
    end                                                                           as amount_discount_booked_shopify
    , aggregates.amount_discount_booked                                           as amount_discount_booked_ns
    , coalesce(amount_discount_booked_shopify, amount_discount_booked_ns)         as amount_discount_booked
    , case
        when aggregate_netsuite.channel_currency_abbreviation = 'CAD'
        then shopify_info.amount_tax_booked_shop * cer.exchange_rate
        else shopify_info.amount_tax_booked_shop
    end                                                                           as amount_tax_booked_shopify
    , aggregates.amount_tax_booked                                                as amount_tax_booked_ns
    , coalesce(shopify_info.amount_tax_booked_shop, aggregates.amount_tax_booked) as amount_tax_booked
    , case
        when aggregate_netsuite.channel_currency_abbreviation = 'CAD'
        then shopify_info.amount_shipping_booked_shop * cer.exchange_rate
        else shopify_info.amount_shipping_booked_shop
    end                                                                           as amount_shipping_booked_shopify
    , aggregates.amount_shipping_booked                                           as amount_shipping_booked_ns
    , coalesce(amount_shipping_booked_shopify, amount_shipping_booked_ns)         as amount_shipping_booked
    , case
        when aggregate_netsuite.channel_currency_abbreviation = 'CAD'
        then shopify_info.amount_paid_booked_shop * cer.exchange_rate
        else shopify_info.amount_paid_booked_shop
    end                                                                           as amount_paid_booked_shopify
    , aggregates.amount_paid_booked                                               as amount_paid_booked_ns
    , coalesce(amount_paid_booked_shopify, amount_paid_booked_ns)                 as amount_paid_booked
    , aggregates.amount_revenue_sold
    , aggregates.amount_product_sold
    , aggregates.amount_discount_sold
    , aggregates.amount_shipping_sold
    , aggregates.amount_tax_sold
    , aggregates.amount_paid_sold
    , aggregates.amount_cogs_fulfilled
    , aggregates.amount_revenue_refunded
    , aggregates.amount_product_refunded
    , aggregates.amount_shipping_refunded
    , aggregates.amount_tax_refunded
    , aggregates.amount_paid_refunded
    , aggregates.revenue
    , aggregates.amount_paid_total
    , aggregates.gross_profit_estimate
    , aggregates.cost_estimate
-- case when aggregate_netsuite.tier like '%O' then true
--      when cust.first_order_id_edw_ns is not null and cust.customer_category = 'D2C' then TRUE
--      else false end as customer_first_order_flag
from
    dim.orders                                  orders
left outer join bridge.netsuite_aggregates as aggregate_netsuite
    on aggregate_netsuite.order_id_edw = orders.order_id_edw
left outer join shopify_info
    on shopify_info.order_id_edw = orders.order_id_edw
left outer join aggregates
    on aggregates.order_id_edw = aggregate_netsuite.order_id_edw

left outer join refund_aggregates               refund
    on refund.order_id_edw = aggregate_netsuite.order_id_edw
left outer join dim.location                    location
    on location.location_id_ns = aggregate_netsuite.location
left outer join fact.currency_exchange_rate      cer
    on aggregate_netsuite.booked_date = cer.effective_date and
       aggregate_netsuite.channel_currency_id_ns = cer.transaction_currency_id_ns
left outer join fulfillment_info
    on fulfillment_info.order_id_edw = orders.order_id_edw
-- LEFT OUTER JOIN fact.customers cust ON cust.first_order_id_edw_ns = orders.order_id_edw
where
    aggregate_netsuite.booked_date >= '2022-01-01T00:00:00Z'
order by
    aggregate_netsuite.booked_date desc