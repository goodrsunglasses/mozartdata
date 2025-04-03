with amazon_seller_data as (
  select
    traffic.date::date as traffic_date
    , traffic.marketplace_id
    , 'Amazon Canada' as marketplace_name
    , traffic.traffic_by_date_sessions as sessions
    , traffic.traffic_by_date_page_views as page_views
    , ceil(traffic.traffic_by_date_page_views * traffic.traffic_by_date_buy_box_percentage / 100) as buy_box_count
  from
    amazon_selling_partner.sales_and_traffic_business_report_daily as traffic
  where
    traffic.marketplace_id = 'A2EUQ1WTGCTBG2'
)

, fact_orders_data as (
  select
    booked_date::date as purchase_date
    , channel
    , count(order_id_edw) as order_count
    , sum(amount_product_sold) as amount_product_sold
  from
    fact.orders
  where
    channel = 'Amazon Canada'
  group by
    booked_date::date
    , channel
)

select
  traffic.traffic_date as event_date
  , traffic.sessions
  , orders.order_count
  , orders.amount_product_sold
  , traffic.page_views
  , traffic.buy_box_count
from
  amazon_seller_data as traffic
left join
  fact_orders_data as orders
  on
    traffic.traffic_date = orders.purchase_date