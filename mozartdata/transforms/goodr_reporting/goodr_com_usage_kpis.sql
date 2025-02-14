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
                                     left join
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
                                     left join
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
  , loyalty_account_totals_ytd as (
                                 select
                                     try_to_timestamp(
                                         trim(
                                             replace(
                                                 platform_account_created_at
                                                 , ' UTC'
                                                 , ''
                                             )
                                         )
                                         , 'YYYY-MM-DD HH24:MI:SS'
                                     )::date  as date
                                   , count(*) as daily_total_created_accounts
                                 from
                                     yotpo_exports.customer_report_010125_021225
                                 where
                                     lower(platform_account_created_at) != 'unknown'
                                 group by
                                     date
                             )
  , loyalty_redeeming_customers_totals_ytd as (
                                 select
                                     day                   as date
                                   , "REDEEMING CUSTOMERS" as redeeming_customers
                                 from
                                     yotpo_exports.daily_redeeming_customers_010124_021225
                             )
, daily_stats as (
                     select
                         sd_ytd.date
                       , sd_ytd.sessions                                                                    as shopify_sessions
                       , sd_last_ytd.sessions                                                               as shopify_sessions_last_year
                       , (sd_ytd.sessions - sd_last_ytd.sessions)                                           as shopify_sessions_diff
                       , sd_ytd.users                                                                       as shopify_users
                       , sd_last_ytd.users                                                                  as shopify_users_last_year
                       , (sd_ytd.users - sd_last_ytd.users)                                                 as shopify_users_diff
                       , sd_ytd.total_customers                                                             as shopify_total_customers
                       , sd_last_ytd.total_customers                                                        as shopify_total_customers_last_year
                       , (sd_ytd.total_customers - sd_last_ytd.total_customers)                             as shopify_total_customers_diff
                       , sd_ytd.new_customers                                                               as shopify_new_customers
                       , sd_last_ytd.new_customers                                                          as shopify_new_customers_last_year
                       , (sd_ytd.new_customers - sd_last_ytd.new_customers)                                 as shopify_new_customers_diff
                       , sd_ytd.sess_completed_checkout                                                     as shopify_sess_completed_checkout
                       , sd_last_ytd.sess_completed_checkout                                                as shopify_sess_completed_checkout_last_year
                       , (sd_ytd.sess_completed_checkout - sd_last_ytd.sess_completed_checkout)             as shopify_sess_completed_checkout_diff
                       , sd_ytd.daily_conversion_rate                                                       as shopify_daily_conversion_rate
                       , sd_last_ytd.daily_conversion_rate                                                  as shopify_daily_conversion_rate_last_year
                       , (sd_ytd.daily_conversion_rate - sd_last_ytd.daily_conversion_rate)                 as shopify_daily_conversion_rate_diff
                       , round(media_ytd.total_spend, 2)                                                    as media_partners_daily_media_spend
                       , round(media_last_ytd.total_spend, 2)                                               as media_partners_daily_media_spend_last_year
                       , round((media_ytd.total_spend - media_last_ytd.total_spend), 2)                     as media_partners_daily_media_spend_diff
                       , round(media_ytd.total_revenue, 2)                                                  as media_partners_daily_media_revenue
                       , round(media_last_ytd.total_revenue, 2)                                             as media_partners_daily_media_revenue_last_year
                       , round((media_ytd.total_revenue - media_last_ytd.total_revenue), 2)                 as media_partners_daily_media_revenue_diff
                       , media_ytd.total_impressions                                                        as media_partners_daily_media_impressions
                       , media_last_ytd.total_impressions                                                   as media_partners_daily_media_impressions_last_year
                       , round((media_ytd.total_impressions - media_last_ytd.total_impressions),
                               2)                                                                           as daily_media_impressions_diff
                       , media_ytd.total_clicks                                                             as daily_media_clicks
                       , media_last_ytd.total_clicks                                                        as daily_media_clicks_last_year
                       , round((media_ytd.total_clicks - media_last_ytd.total_clicks), 2)                   as daily_media_clicks_diff
                       , revenue_ytd.daily_total_revenue                                                    as daily_total_revenue
                       , revenue_last_ytd.daily_total_revenue                                               as daily_total_revenue_last_year
                       , round((revenue_ytd.daily_total_revenue - revenue_last_ytd.daily_total_revenue),
                               2)                                                                           as daily_total_revenue_diff
                       , loyalty_accounts_ytd.daily_total_created_accounts                                  as daily_yotpo_account_total
                       , loyalty_redeeming_ytd.redeeming_customers                                          as daily_yotpo_redeeming_customers_total
                       , round((media_partners_daily_media_impressions / shopify_users), 2)                                as customer_acquisition_cost
                       , round(((media_ytd.total_spend * 1000) / media_ytd.total_impressions),
                               2)                                                                           as eff_cost_per_mile
                       , round((revenue_last_ytd.daily_total_revenue / sd_ytd.users), 2)                    as average_revenue_per_user
                       , round(
                             (loyalty_accounts_ytd.daily_total_created_accounts / sd_ytd.total_customers)
                             , 2
                         )                                                                                  as daily_loyalty_account_creation_rate
                     from
                         shopify_data_this_ytd                      as sd_ytd
                         left join
                             shopify_data_last_ytd                  as sd_last_ytd
                                 on
                                 day(sd_ytd.date) = day(sd_last_ytd.date)
                                     and month(sd_ytd.date) = month(sd_last_ytd.date)
                         left join
                             media_totals_this_ytd                  as media_ytd
                                 on
                                 day(sd_ytd.date) = day(media_ytd.date)
                                     and month(sd_ytd.date) = month(media_ytd.date)
                         left join
                             media_totals_last_ytd                  as media_last_ytd
                                 on
                                 day(sd_ytd.date) = day(media_last_ytd.date)
                                     and month(sd_ytd.date) = month(media_last_ytd.date)
                         left join
                             revenue_totals_this_ytd                as revenue_ytd
                                 on
                                 day(sd_ytd.date) = day(revenue_ytd.date)
                                     and month(sd_ytd.date) = month(revenue_ytd.date)
                         left join
                             revenue_totals_last_ytd                as revenue_last_ytd
                                 on
                                 day(sd_ytd.date) = day(revenue_last_ytd.date)
                                     and month(sd_ytd.date) = month(revenue_last_ytd.date)
                         left join
                             loyalty_account_totals_ytd             as loyalty_accounts_ytd
                                 on
                                 day(sd_ytd.date) = day(loyalty_accounts_ytd.date)
                                     and month(sd_ytd.date) = month(loyalty_accounts_ytd.date)
                         left join
                             loyalty_redeeming_customers_totals_ytd as loyalty_redeeming_ytd
                                 on
                                 day(sd_ytd.date) = day(loyalty_redeeming_ytd.date)
                                     and month(sd_ytd.date) = month(loyalty_redeeming_ytd.date)
                 )
-- select
--     date_trunc('month', dateadd('year', -1, date)) as month
--     , sum(daily_stats.sessions_last) as sessions
--     , sum(daily_stats.sess_completed_checkout_last) as sessions_completed_checkout
--     , sum(daily_stats.users_last) as total_users
--     , sum(daily_stats.daily_total_revenue_last) as total_revenue
--     -- , sum(daily_stats.daily_loyalty_redeeming_customers_total) as total_redeeming_customers
--     , sum(daily_stats.total_customers_last) as total_customers
--     , sum(daily_stats.daily_media_spend_last) as total_media_spend
--     , sum(daily_stats.daily_media_impressions_last) as total_impressions
--     -- , sum(daily_loyalty_account_total) as total_accounts_created
--     , sum(daily_stats.new_customers_last) as new_customers
-- from
--     daily_stats
-- where
--     date between '2025-01-01' and '2025-01-31'
-- group by
--     month

select
    date_trunc('month', dateadd('year', -1, date)) as month
    , sum(daily_stats.sessions_last) as sessions
    , sum(daily_stats.sess_completed_checkout_last) as sessions_completed_checkout
    , sum(daily_stats.users_last) as total_users
    , sum(daily_stats.daily_total_revenue_last) as total_revenue
    -- , sum(daily_stats.daily_loyalty_redeeming_customers_total) as total_redeeming_customers
    , sum(daily_stats.total_customers_last) as total_customers
    , sum(daily_stats.daily_media_spend_last) as total_media_spend
    , sum(daily_stats.daily_media_impressions_last) as total_impressions
    -- , sum(daily_loyalty_account_total) as total_accounts_created
    , sum(daily_stats.new_customers_last) as new_customers
from
    daily_stats
where
    date between '2025-01-01' and '2025-01-31'
group by
    month





