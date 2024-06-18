WITH CTE_MY_DATE AS (
    SELECT DATEADD(DAY, SEQ4(), '2000-01-01') AS MY_DATE
    FROM TABLE(GENERATOR(ROWCOUNT=>100000))
), dim_date as
(
SELECT
  MY_DATE                                                                                 as date_timestamp
, date(MY_DATE)                                                                           as date
, TO_CHAR(MY_DATE, 'YYYYMMDD')::int                                                       as date_int
, TO_VARCHAR(MY_DATE::DATE, 'YYYYMM')                                                     as yrmo
, concat(YEAR(MY_DATE), 'Q', QUARTER(MY_DATE))                                            as yrq
, YEAR(MY_DATE)                                                                           as year
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
  dd.date
, dd.week_start_date as media_period_start
, dateadd(day, 13, dd.week_start_date) as media_period_end
, CEIL(week_of_year / 2.0) AS media_week_group
, CONCAT('Week ', CEIL(week_of_year / 2.0) * 2 - 1, ' / ', CEIL(week_of_year / 2.0)  * 2) as media_week_label
from
    dim_date dd
)
select
    dd.*
, wp.media_period_start
, wp.media_period_end
, wp.media_week_group
, wp.media_week_label
from
    dim_date dd
left join
    week_periods wp
on dd.date = wp.date