-- noinspection SqlCurrentSchemaInspectionForFile

-- noinspection SqlCurrentSchemaInspectionForFile

-- noinspection SqlCurrentSchemaInspectionForFile

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
    shopify_data_this_ytd as (
                                 select
                                     d.date::date                               as date
                                   , shopify.sessions
                                   , shopify."ONLINE STORE VISITORS"            as users
                                   , shopify."NEW CUSTOMERS"                    as new_customers
                                   , shopify.customers                          as total_customers
                                   , shopify."SESSIONS THAT COMPLETED CHECKOUT" as sess_completed_checkout
                                   , shopify."CONVERSION RATE"                  as daily_conversion_rate
                                 from
                                     dim.date                                       as d
                                     inner join
                                         shopify_exports.kpi_data_20240101_20250206 as shopify
                                             on
                                             d.date = shopify.day::date
                                 where
                                       d.date >= date_trunc('year', current_date)
                                   and d.date <= current_date
                             )
  , shopify_data_last_ytd as (
                                 select
                                     d.date::date                               as date
                                   , shopify.sessions
                                   , shopify."ONLINE STORE VISITORS"            as users
                                   , shopify."NEW CUSTOMERS"                    as new_customers
                                   , shopify.customers                          as total_customers
                                   , shopify."SESSIONS THAT COMPLETED CHECKOUT" as sess_completed_checkout
                                   , shopify."CONVERSION RATE"                  as daily_conversion_rate
                                 from
                                     dim.date                                       as d
                                     inner join
                                         shopify_exports.kpi_data_20240101_20250206 as shopify
                                             on
                                             d.date = shopify.day::date
                                 where
                                       d.date >= date_trunc('year', dateadd(year, -1, current_date))
                                   and d.date <= dateadd(year, -1, current_date)
                             )
  , media_totals_this_ytd as (
                                 select
                                     date
                                   , sum(spend)       as total_spend
                                   , sum(revenue)     as total_revenue
                                   , sum(impressions) as total_impressions
                                   , sum(clicks)      as total_clicks
                                 from
                                     goodr_reporting.performance_media as pm
                                 where
                                       lower(pm.account_country) = 'usa'
                                   and date >= date_trunc('year', current_date)
                                   and date <= current_date
                                 group by
                                     date
                             )
  , media_totals_last_ytd as (
                                 select
                                     date
                                   , sum(spend)       as total_spend
                                   , sum(revenue)     as total_revenue
                                   , sum(impressions) as total_impressions
                                   , sum(clicks)      as total_clicks
                                 from
                                     goodr_reporting.performance_media as pm
                                 where
                                       lower(pm.account_country) = 'usa'
                                   and date >= date_trunc('year', dateadd(year, -1, current_date))
                                   and date <= dateadd(year, -1, current_date)
                                 group by
                                     date
                             )
  , revenue_totals_this_ytd as (
                                 select
                                     gl_tran.transaction_date          as date
                                   , round(sum(gl_tran.net_amount), 2) as daily_total_revenue
                                 from
                                     dev_reporting.gl_transaction as gl_tran
                                 where
                                       gl_tran.posting_flag = true
                                   and lower(gl_tran.channel) = 'goodr.com'
                                   and gl_tran.account_number in (
                                                                  4000, 4110, 4210
                                     )
                                   and gl_tran.transaction_date >= date_trunc('year', current_date)
                                   and gl_tran.transaction_date <= current_date
                                 group by
                                     gl_tran.transaction_date
                             )
  , revenue_totals_last_ytd as (
                                 select
                                     gl_tran.transaction_date          as date
                                   , round(sum(gl_tran.net_amount), 2) as daily_total_revenue
                                 from
                                     dev_reporting.gl_transaction as gl_tran
                                 where
                                       gl_tran.posting_flag = true
                                   and lower(gl_tran.channel) = 'goodr.com'
                                   and gl_tran.account_number in (
                                                                  4000, 4110, 4210
                                     )
                                   and gl_tran.transaction_date >= date_trunc('year', dateadd(year, -1, current_date))
                                   and gl_tran.transaction_date <= dateadd(year, -1, current_date)
                                 group by
                                     gl_tran.transaction_date
                             )
select
    sd_ytd.date
  , sd_ytd.sessions                                                                    as sessions_ytd
  , sd_last_ytd.sessions                                                               as sessions_last_ytd
  , (sd_ytd.sessions - sd_last_ytd.sessions)                                           as sessions_diff
  , sd_ytd.users                                                                       as users_ytd
  , sd_last_ytd.users                                                                  as users_last_ytd
  , (sd_ytd.users - sd_last_ytd.users)                                                 as users_diff
  , sd_ytd.total_customers                                                             as total_customers_ytd
  , sd_last_ytd.total_customers                                                        as total_customers_last_ytd
  , (sd_ytd.total_customers - sd_last_ytd.total_customers)                             as total_customers_diff
  , sd_ytd.new_customers                                                               as new_customers_ytd
  , sd_last_ytd.new_customers                                                          as new_customers_last_ytd
  , (sd_ytd.new_customers - sd_last_ytd.new_customers)                                 as new_customers_diff
  , sd_ytd.sess_completed_checkout                                                     as sess_completed_checkout_ytd
  , sd_last_ytd.sess_completed_checkout                                                as sess_completed_checkout_last_ytd
  , (sd_ytd.sess_completed_checkout - sd_last_ytd.sess_completed_checkout)             as sess_completed_checkout_diff
  , sd_ytd.daily_conversion_rate                                                       as daily_conversion_rate_ytd
  , sd_last_ytd.daily_conversion_rate                                                  as daily_conversion_rate_last_ytd
  , (sd_ytd.daily_conversion_rate - sd_last_ytd.daily_conversion_rate)                 as daily_conversion_rate_diff
  , round(media_ytd.total_spend, 2)                                                    as daily_media_spend_ytd
  , round(media_last_ytd.total_spend, 2)                                               as daily_media_spend_last_ytd
  , round((media_ytd.total_spend - media_last_ytd.total_spend), 2)                     as daily_media_spend_diff
  , round(media_ytd.total_revenue, 2)                                                  as daily_media_revenue_ytd
  , round(media_last_ytd.total_revenue, 2)                                             as daily_media_revenue_last_ytd
  , round((media_ytd.total_revenue - media_last_ytd.total_revenue), 2)                 as daily_media_revenue_diff
  , media_ytd.total_impressions                                                        as daily_media_impressions_ytd
  , media_last_ytd.total_impressions                                                   as daily_media_impressions_last_ytd
  , round((media_ytd.total_impressions - media_last_ytd.total_impressions), 2)         as daily_media_impressions_diff
  , media_ytd.total_clicks                                                             as daily_media_clicks_ytd
  , media_last_ytd.total_clicks                                                        as daily_media_clicks_last_ytd
  , round((media_ytd.total_clicks - media_last_ytd.total_clicks), 2)                   as daily_media_clicks_diff
  , revenue_ytd.daily_total_revenue                                                    as daily_total_revenue_ytd
  , revenue_last_ytd.daily_total_revenue                                               as daily_total_revenue_last_ytd
  , round((revenue_ytd.daily_total_revenue - revenue_last_ytd.daily_total_revenue), 2) as daily_total_revenue_diff
  , round((daily_media_impressions_ytd / users_ytd), 2)                                as customer_acquisition_cost_ytd
  , round(((media_ytd.total_spend * 1000) / media_ytd.total_impressions), 2)           as eff_cost_per_mile_ytd
  , round((revenue_last_ytd.daily_total_revenue / sd_ytd.users), 2)                    as average_revenue_per_user_ytd
from
    shopify_data_this_ytd       as sd_ytd
    left join
        shopify_data_last_ytd   as sd_last_ytd
            on
            day(sd_ytd.date) = day(sd_last_ytd.date)
                and month(sd_ytd.date) = month(sd_last_ytd.date)
    left join
        media_totals_this_ytd   as media_ytd
            on
            day(sd_ytd.date) = day(media_ytd.date)
                and month(sd_ytd.date) = month(media_ytd.date)
    left join
        media_totals_last_ytd   as media_last_ytd
            on
            day(sd_ytd.date) = day(media_last_ytd.date)
                and month(sd_ytd.date) = month(media_last_ytd.date)
    left join
        revenue_totals_this_ytd as revenue_ytd
            on
            day(sd_ytd.date) = day(revenue_ytd.date)
                and month(sd_ytd.date) = month(revenue_ytd.date)
    left join
        revenue_totals_last_ytd as revenue_last_ytd
            on
            day(sd_ytd.date) = day(revenue_last_ytd.date)
                and month(sd_ytd.date) = month(revenue_last_ytd.date)



