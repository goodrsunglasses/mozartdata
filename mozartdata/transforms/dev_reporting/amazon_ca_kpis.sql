/*
    Table name:
        dev_reporting.amazon_ca_kpis
    Created:
        04-03-2025
    Purpose:
        Shows the KPIs for Amazon.ca sales channel.
    Schema:
        event_date: The date that is being reported on
            Primary Key
        sessions: Number of sessions being reported by Amazon Seller Central
        page_views: number of page views being reported by Amazon Seller Central
        buy_box_count: number of page views where we had the "buy box". This means we
            had the lowest price for that item available on Amazon.
        order_count: number of orders being reported by fact.orders. This is lower than
            Amazon Seller Central because fact.orders involves NS, which doesn't get
            Amazon order info until the order ships.
        amount_product_sold: the sales amount of product as reported by fact.orders.
        customer_count: number of customers who bought a product as reported by
            fact.orders
        amazon_spend: amount spent on Amazon Ads as reported by Amazon Ads
        amount_attributed_product_sold: sales amount of product sold attributed to ads
            as reported by Amazon Ads.
*/

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
                                  booked_date                  as purchase_date
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