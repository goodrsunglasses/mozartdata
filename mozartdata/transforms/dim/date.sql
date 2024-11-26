/*
Purpose: provide information about each day in a calendar year. One row per date in a year.

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )
    .CTE_MY_DATE as (
    SELECT DATEADD(DAY, SEQ4(), '2000-01-01') AS MY_DATE
    FROM TABLE(GENERATOR(ROWCOUNT=>100000))
    )
                      , dim_date as
(
SELECT
  MY_DATE                                                                                 as date_timestamp
, date(MY_DATE)                                                                           as date
, TO_CHAR(MY_DATE, 'YYYYMMDD')::int                                                       as date_int
, TO_VARCHAR(MY_DATE::DATE, 'YYYYMM')                                                     as yrmo
, concat(YEAR(MY_DATE), 'Q', QUARTER(MY_DATE))                                            as yrq
, YEAR(MY_DATE)                                                                           as year
, quarter(my_date)                                                                        as quarter
, MONTH(MY_DATE)                                                                          as month
, MONTHNAME(MY_DATE)                                                                      as month_name
, DAY(MY_DATE)                                                                            as day
, DAYOFWEEK(MY_DATE)                                                                      as day_of_week
, DAYNAME(MY_DATE)                                                                        as day_of_week_name
, DATE(DATE_TRUNC(week, MY_DATE))                                                         as week_start_date
, DATE(DATEADD('DAY', 7 - DAYOFWEEK(MY_DATE), MY_DATE))                                   AS week_end_date
, WEEKOFYEAR(MY_DATE)                                                                     as week_of_year
, YEAROFWEEK(MY_DATE)                                                                     as week_year
, CASE
    WHEN month = MONTH(DATE_TRUNC('MONTH', week_start_date)) THEN
        LEAST(DATEDIFF(DAY, week_start_date, LAST_DAY(week_start_date)), 7)
    ELSE
        LEAST(7 - DATEDIFF(DAY, week_start_date, LAST_DAY(week_start_date)), 7)
END                                                                                     AS week_days_in_current_month
, case
    when week_days_in_current_month > 7 then 0
    else 7 - week_days_in_current_month end                                             as week_days_in_other_month
, DAYOFYEAR(MY_DATE)                                                                      as day_of_year
, CONCAT(MONTH(MY_DATE), '-', DAY(MY_DATE))                                               as day_month
, google_sheets.sales_seasons.season                                                      as sales_season
, TO_CHAR(MY_DATE, 'Mon YYYY')                                                            as posting_period
FROM CTE_MY_DATE
  LEFT JOIN google_sheets.sales_seasons on day_month = google_sheets.sales_seasons.date
), week_periods as
(
select distinct
  dd.week_start_date as media_period_start
, dateadd(day, 13, dd.week_start_date) as media_period_end
, CEIL(week_of_year / 2.0) AS media_period_group
, CONCAT('Week ', CEIL(week_of_year / 2.0) * 2 - 1, ' / ', CEIL(week_of_year / 2.0)  * 2) as media_period_label
, dd.week_year
, dd.week_of_year
from
    dim_date dd
), distinct_weeks as
(
    select
        wp.week_year
    ,   wp.week_of_year
    ,   wp.media_period_group
    ,   wp.media_period_label
    ,   min(wp.media_period_start) over (partition by wp.media_period_group, wp.week_year) as media_period_start_date
    ,   min(wp.media_period_end) over (partition by wp.media_period_group, wp.week_year) as media_period_end_date
    from
        week_periods wp
)
select
    dd.*
, min(dd.date) over (partition by dd.sales_season, dd.year) as season_start_date
, max(dd.date) over (partition by dd.sales_season, dd.year) as season_end_date
, dw.media_period_start_date
, dw.media_period_end_date
, dw.media_period_group
, dw.media_period_label
from
    dim_date dd
left join
    distinct_weeks dw
on dd.week_of_year = dw.week_of_year
and dd.week_year = dw.week_year