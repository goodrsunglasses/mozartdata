/*
    This table shows the daily KPIs for goodr.com usage.
    Columns:
        date:
            Date reported on. This comes from dim.date to prevent issues
            with a date not existing in Shopify.
        sessions:
            Total sessions as defined by Shopify for each day.
        users:
            Labeled "Online store visitors" in Shopify, this is the number of
            unique users that visited the site wach day regardless of their
            session count.
        total_customers:
            This is the total number of users that bought a product in a day.
    Todos:
        - handle leap years
    More to come

 */

with
    marketing_totals as (
                            select
                                date::date           as date
                              , round(sum(spend), 2) as total_spend
                              , sum(impressions)     as total_impressions
                              , sum(clicks)          as total_clicks
                            from
                                goodr_reporting.performance_media as pm
                            where
                                  lower(pm.account_country) = 'usa'
                              and date >= '2024-01-01'
                              and date <= current_date
                            group by
                                date
                        )
  , revenue_totals as (
                            select
                                gl_tran.transaction_date::date    as date
                              , round(sum(gl_tran.net_amount), 2) as total_revenue
                            from
                                fact.gl_transaction as gl_tran
                            where
                                  gl_tran.posting_flag = true
                              and lower(gl_tran.channel) = 'goodr.com'
                              and gl_tran.account_number in (
                                                             4000, 4110, 4210
                                )
                              and gl_tran.transaction_date >= '2024-01-01'
                              and gl_tran.transaction_date <= current_date
                            group by
                                gl_tran.transaction_date
                        )
  , new_customer_revenue_totals as (
                            select
                                cust.first_order_date_shopify::date as date
                              , round(
                                    sum(
                                        amount_product + amount_discount + amount_refunded
                                    ), 2
                                )                                   as new_customer_product_sales
                            from
                                fact.customers                as cust
                                inner join
                                    fact.customer_shopify_map as shopify
                                        on
                                        cust.customer_id_edw = shopify.customer_id_edw
                                left join
                                    fact.order_item_detail    as oid
                                        on
                                        cust.first_order_id_edw_shopify = oid.order_id_edw
                            where
                                  lower(shopify.store) = 'goodr.com'
                              and lower(oid.record_type) in (
                                                             'cashsale', 'invoice', 'cashrefund'
                                )
                              and lower(oid.plain_name) not in (
                                                                'tax', 'shipping'
                                )
                              and cust.first_order_date_shopify >= '2024-01-01'
                            group by
                                cust.first_order_date_shopify
                            order by
                                cust.first_order_date_shopify

                        )
select
    d.date::date
  , shopify.sessions
  , shopify.users
  , shopify.total_customers
  , shopify.new_customers
  , (shopify.total_customers - shopify.new_customers)                             as existing_customers
  , shopify.sessions_completed_checkout
  , round(shopify.conversion_rate, 8)                                             as conversion_rate
  , marketing.total_spend
  , marketing.total_impressions
  , marketing.total_clicks
  , gl_tran.total_revenue                                                         as total_product_sales
  , new_customer_sales.new_customer_product_sales
  , (gl_tran.total_product_sales - new_customer_sales.new_customer_product_sales) as existing_customer_product_sales
from
    dim.date                                    as d
    left join
        staging.shopify_kpi_exports_aggregation as shopify
            on
            d.date = shopify.date
    left join
        marketing_totals                        as marketing
            on
            d.date = marketing.date
    left join
        revenue_totals                          as gl_tran
            on
            d.date = gl_tran.date
    left join
        new_customer_revenue_totals             as new_customer_sales
            on
            d.date = new_customer_sales.date
where
      d.date >= '2024-01-01'
  and d.date <= current_date
order by
    d.date asc
