with conversion as (
    select
        currency_exchange_rate.effective_date
        , currency_exchange_rate.exchange_rate
    from
        fact.currency_exchange_rate
    where
      currency_exchange_rate.transaction_currency_abbreviation = 'CAD'
    qualify
      row_number() over (order by currency_exchange_rate.effective_date desc) = 1
)
select
    oi.sku
    , oi.display_name
    , p.family
    , p.collection
    , o.sold_date
    , o.store                                                        as channel
    , iff(
          o.sold_date between '2023-11-22' and '2023-11-28'
          , 'BFCM-2023'
          , 'BFCM-2024'
      )                                                              as bfcm_period
    , case 
      when o.sold_date in ('2024-11-26') then '0-Tues'
      when o.sold_date in ('2023-11-22','2024-11-27') then '1-Wed'
      when o.sold_date in ('2023-11-23','2024-11-28') then '2-Thu/Thanksgiving'
      when o.sold_date in ('2023-11-24','2024-11-29') then '3-Fri/BF'
      when o.sold_date in ('2023-11-25','2024-11-30') then '4-Sat'
      when o.sold_date in ('2023-11-26','2024-12-01') then '5-Sun'
      when o.sold_date in ('2023-11-27','2024-12-02') then '6-Mon/CM'
      when o.sold_date in ('2023-11-28','2024-12-03') then '7-Tues'
      end bfcm_day
    , count(distinct oi.order_id_edw)                                as order_count
    , sum(oi.quantity_booked)                                        as quantity_booked
    , iff(
          o.store in ('Specialty CAN', 'Goodr.ca')
          , sum(oi.amount_product_booked) * avg(c.exchange_rate)
          , sum(oi.amount_product_booked)
      )                                                              as amount_product
    , iff(
          o.store in ('Specialty CAN', 'Goodr.ca')
          , sum(oi.amount_sales_booked) * avg(c.exchange_rate)
          , sum(oi.amount_sales_booked)
      )                                                              as amount_sales
    , iff(
          o.store in ('Specialty CAN', 'Goodr.ca')
          , sum(oi.amount_yotpo_discount) * avg(c.exchange_rate)
          , sum(oi.amount_yotpo_discount)
      )                                                              as amount_yotpo_discount
    , iff(
          o.store in ('Specialty CAN', 'Goodr.ca')
          , sum(oi.amount_standard_discount) * avg(c.exchange_rate)
          , sum(oi.amount_standard_discount)
      )                                                              as amount_standard_discount
    , iff(
          o.store in ('Specialty CAN', 'Goodr.ca')
          , sum(oi.amount_refund_product) * avg(c.exchange_rate)
          , sum(oi.amount_refund_product)
      )                                                              as amount_refunded
    , iff(
          o.store in ('Specialty CAN', 'Goodr.ca')
          , sum(oi.amount_gift_card_sold) * avg(c.exchange_rate)
          , sum(oi.amount_gift_card_sold)
      )                                                              as amount_gift_card
    , iff(
          oi.sku like 'GC%'
          , true
          , false
      )                                                              as gift_card_flag
    , p.merchandise_class                                            as style_family
    , min(p.d2c_launch_date) over (partition by p.merchandise_class) as model_start_date
    , iff(
          model_start_date > '2024-01-01'
          , 'true'
          , 'false'
      )                                                              as new_model_flag
from
    fact.shopify_order_item oi
    inner join
        dim.product         p
        on
            oi.sku = p.product_id_edw
    left join
        fact.shopify_orders o
        on
            oi.order_id_edw = o.order_id_edw
    left join
        conversion          c
        on
            1 = 1
where
    (
      o.sold_date between '2023-11-22' and '2023-11-28'
      or o.sold_date between '2024-11-26' and '2024-12-03'
    )
    and o.store not in (
        'Goodrwill'
    )
group by
      oi.sku
    , oi.display_name
    , p.family
    , p.collection
    , o.sold_date
    , o.store
    , c.exchange_rate
    , p.d2c_launch_date
    , p.merchandise_class