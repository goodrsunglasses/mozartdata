/*--first grab the netsuite info from dim.orders which implicitly should only
  have parent transactions from NS.
 */
with
    netsuite_info as (
        select
            orders.order_id_edw
            , orders.transaction_id_ns       as parent_id
            , line.channel
            , category.currency_id_ns        as channel_currency_id_ns
            , category.currency_abbreviation as channel_currency_abbreviation
            , line.email
            , line.customer_id_ns
            , line.customer_id_edw
            , line.tier
            , line.location
            , line.warranty_order_id_ns
            , category.customer_category     as b2b_d2c
            , category.model
        from
            dim.orders                       as orders
        left outer join
             fact.order_line                 as line
             on
                 line.transaction_id_ns = orders.transaction_id_ns
        left outer join
             dim.channel                     as category
             on
                 category.name = line.channel
        where
            /* no need for checking if its a parent as the only transaction_id_ns's
               that are in dim.orders are parents
             */
             orders.transaction_id_ns is not null
    )
select distinct
    ns_parent.order_id_edw
    , ns_parent.parent_id
    , ns_parent.channel
    , ns_parent.channel_currency_id_ns
    , ns_parent.channel_currency_abbreviation
    , ns_parent.email
    , ns_parent.customer_id_ns
    , ns_parent.customer_id_edw
    , ns_parent.tier
    , ns_parent.location
    , ns_parent.warranty_order_id_ns
    , ns_parent.b2b_d2c
    , ns_parent.model
    , max(status_flag_edw) over ( partition by orderline.order_id_edw )                                                                                                     as status_flag_edw
    , max(orderline.is_exchange) over ( partition by orderline.order_id_edw )                                                                                               as is_exchange
    , first_value(transaction_date)
             over (
                 partition by
                     orderline.order_id_edw
                 order by
                     case
                        when record_type = 'salesorder'
                        then 1
                        else 2
                     end
                     , transaction_created_timestamp_pst asc
             )                                         as booked_date
    , first_value(case
                 when orderline.record_type in ('cashsale', 'invoice')
                     then orderline.transaction_date
                 else null
             end) over (
                 partition by
                     orderline.order_id_edw
                 order by
                     case
                        when orderline.record_type in ('cashsale', 'invoice')
                        then 1
                        else 2
                     end
                     , orderline.transaction_created_timestamp_pst asc
            )                                          as sold_date
    , first_value(case
                 when record_type = 'itemfulfillment'
                     then transaction_date
                 else null
             end) over (
                 partition by
                     orderline.order_id_edw
                 order by
                     case
                         when record_type = 'itemfulfillment'
                         then 1
                         else 2
                     end
                     , transaction_created_timestamp_pst desc
             )                                       as fulfillment_date
    , first_value(shipping_window_start_date)
             ignore nulls over (
                 partition by
                     orderline.order_id_edw
                 order by
                     shipping_window_start_date desc
             )                                       as shipping_window_start_date
    , first_value(shipping_window_end_date)
             ignore nulls over (
                 partition by
                     orderline.order_id_edw
                 order by
                     shipping_window_end_date desc
             )                                       as shipping_window_end_date
from
    netsuite_info                                    as ns_parent
left outer join
    fact.order_line                                  as orderline
    on
        orderline.order_id_edw = ns_parent.order_id_edw

