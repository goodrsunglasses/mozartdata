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

    More to come

 */

select
    d.date::date                                    as date
    , shopify.sessions
    , shopify."ONLINE STORE VISITORS"               as users
    , shopify."NEW CUSTOMERS"                       as new_customers
    , shopify.customers                             as total_customers
    , shopify."SESSIONS THAT COMPLETED CHECKOUT"    as sess_completed_checkout
    , shopify."CONVERSION RATE"                     as daily_conversion_rate
from
    dim.date                                        as d
inner join
    shopify_exports.kpi_data_20240101_20250206      as shopify
    on
        d.date = shopify.day::date
where
    d.date >= '2024-01-01'
