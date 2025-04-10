with root_table as (
    select
      *
    from
      mozart.pipeline_root_table
)
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
union all
select
    day::date as date
    , "REDEEMING CUSTOMERS"
from
    yotpo_exports.daily_redeeming_customers_021725_030925
union all
select
    day::date as date
    , "REDEEMING CUSTOMERS"
from
    yotpo_exports.daily_redeeming_customers_031025_033125
union all
select
    day::date as date
    , "REDEEMING CUSTOMERS"
from
    yotpo_exports.daily_redeeming_customers_040125_040925