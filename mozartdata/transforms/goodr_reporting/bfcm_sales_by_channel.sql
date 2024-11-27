select
    s.sold_date
    , s.channel
    , s.bfcm_period
    , sum(s.order_count)                           as order_count
    , sum(s.quantity_booked)                       as quantity_booked
    , sum(s.amount_product)                        as amount_product
    , sum(s.amount_sales)                          as amount_sales
    , sum(s.amount_yotpo_discount)                 as amount_yotpo_discount
    , sum(s.amount_refunded)                       as amount_refunded
    , sum(s.amount_sales) - sum(s.amount_refunded) as amount_net_sales
    , sum(s.amount_gift_card)                      as amount_gift_card
    , sum(
        iff(
            s.new_model_flag = 'true'
            , s.order_count
            , 0
        )
    )                                            as new_model_order_count
    , sum(
        iff(
            s.new_model_flag = 'true'
            , s.amount_sales
            , 0
        )
    )                                            as new_model_amount_sales
from
    goodr_reporting.bfcm_sales_by_sku s
group by
    all