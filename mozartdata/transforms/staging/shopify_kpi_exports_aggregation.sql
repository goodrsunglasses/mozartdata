select
    day::date                          as event_date
  , "ONLINE STORE VISITORS"            as users
  , sessions                           as sessions
  , "NEW CUSTOMERS"                    as new_customers
  , customers                          as total_customers
  , "CONVERSION RATE"                  as conversion_rate
  , "SESSIONS THAT COMPLETED CHECKOUT" as sessions_completed_checkout
from
    shopify_exports.kpi_data_20240101_20250205
union all
select
    day::date
  , "ONLINE STORE VISITORS"
  , sessions
  , "NEW CUSTOMERS"
  , customers
  , "CONVERSION RATE"
  , "SESSIONS THAT COMPLETED CHECKOUT"
from
    shopify_exports.kpi_data_20250206_20250216