with order_details as
  (
    select
      o.sold_date
    , o.store
    , sum(shipping_sold) as shipping
    , sum(amount_tax_sold) as tax
    from
      fact.shopify_orders o
    group by all
  )
select
    s.sold_date
    , s.channel
    , s.bfcm_period
    , s.bfcm_day
    , sum(s.order_count)                           as order_count
    , sum(s.quantity_booked)                       as quantity_booked
    , sum(s.amount_product)                        as amount_product
    , sum(s.amount_sales)                          as amount_sales
    , sum(s.amount_yotpo_discount)                 as amount_yotpo_discount
    , sum(s.amount_standard_discount)*-1              as amount_standard_discount
    , o.shipping
    , o.tax
    , sum(s.amount_refunded)*-1                       as amount_refunded
    , sum(s.amount_product) - sum(s.amount_standard_discount) + o.shipping - sum(s.amount_refunded)-sum(s.amount_gift_card) as amount_net_sales_dwh
    , sum(s.amount_product) - sum(s.amount_standard_discount) - sum(s.amount_yotpo_discount) + o.shipping + o.tax - sum(s.amount_refunded)-sum(s.amount_gift_card) as amount_net_sales_shopify
    , sum(s.amount_gift_card)*-1                      as amount_gift_card
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
left join
  order_details o
    on s.channel = o.store
    and s.sold_date = o.sold_date
group by
    all