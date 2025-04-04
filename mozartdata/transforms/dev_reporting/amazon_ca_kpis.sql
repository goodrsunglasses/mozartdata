with
    amazon_seller_data as (
                              select
                                  traffic.date::date                 as traffic_date
                                , traffic.marketplace_id
                                , 'Amazon Canada'                    as marketplace_name
                                , traffic.traffic_by_date_sessions   as sessions
                                , traffic.traffic_by_date_page_views as page_views
                                , ceil(traffic.traffic_by_date_page_views * traffic.traffic_by_date_buy_box_percentage /
                                       100)                          as buy_box_count
                              from
                                  amazon_selling_partner.sales_and_traffic_business_report_daily as traffic
                              where
                                  traffic.marketplace_id = 'A2EUQ1WTGCTBG2'
                          )

  , fact_orders_data as (
                              select
                                  booked_date::date            as purchase_date
                                , channel
                                , count(distinct order_id_edw) as order_count
                                , sum(amount_product_sold)     as amount_product_sold
                                , count(customer_id_edw)       as customer_count
                              from
                                  fact.orders
                              where
                                  channel = 'Amazon Canada'
                              group by
                                  booked_date::date
                                , channel
                          )

  , amazon_ads_data as (
                              select
                                  date::date     as media_date
                                , sum(spend)     as amazon_spend
                                , sum(sales_1_d) as amount_attributed_product_sold
                              from
                                  amazon_ads.campaign_level_report
                              where
                                  campaign_budget_currency_code = 'CAD'
                              group by
                                  date::date
                          )

select
    traffic.traffic_date as event_date
  , traffic.sessions
  , traffic.page_views
  , traffic.buy_box_count
  , orders.order_count
  , orders.amount_product_sold
  , orders.customer_count
  , amazon_ads.amazon_spend
  , amazon_ads.amount_attributed_product_sold
from
    amazon_seller_data   as traffic
    left join
        fact_orders_data as orders
            on
            traffic.traffic_date = orders.purchase_date
    left join
        amazon_ads_data  as amazon_ads
            on
            traffic.traffic_date = amazon_ads.media_date