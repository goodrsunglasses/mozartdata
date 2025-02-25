select
    day::date as event_date
    , "REDEEMING CUSTOMERS" as redeeming_customers
from
    yotpo_exports.daily_redeeming_customers_010124_021125
union all
select
    day::date as date
    , "REDEEMING CUSTOMERS"
from
    yotpo_exports.daily_redeeming_customers_021225_021625