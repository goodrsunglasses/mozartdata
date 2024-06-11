WITH CTE_MY_DATE AS (
    SELECT DATEADD(DAY, SEQ4(), '2000-01-01') AS MY_DATE
    FROM TABLE(GENERATOR(ROWCOUNT=>100000))
)
SELECT MY_DATE as date_timestamp
    , date(MY_DATE) as date
    , TO_CHAR(MY_DATE, 'YYYYMMDD')::int as date_int
    , TO_VARCHAR(MY_DATE::DATE,'YYYYMM') as yrmo
    , concat(YEAR(MY_DATE),'Q',QUARTER(MY_DATE)) as yrq
    , YEAR(MY_DATE) as year
    , MONTH(MY_DATE) as month
    , MONTHNAME(MY_DATE) as month_name   
    , DAY(MY_DATE) as day
    , DAYOFWEEK(MY_DATE) as day_of_week
    , DAYNAME(MY_DATE) as day_of_week_name
    , DATE(DATE_TRUNC(week,MY_DATE)) as week_start_date
    , DATE(DATEADD('DAY', 7 - DAYOFWEEK(MY_DATE), MY_DATE)) AS week_end_date
    , WEEKOFYEAR(MY_DATE) as week_of_year
    , YEAROFWEEK(MY_DATE) as week_year
    , CASE
      WHEN month = MONTH(DATE_TRUNC('MONTH', week_start_date)) THEN 
        LEAST(DATEDIFF(DAY, week_start_date, LAST_DAY(week_start_date)),7)
      ELSE
        LEAST(7 - DATEDIFF(DAY, week_start_date, LAST_DAY(week_start_date)),7)
    END AS week_days_in_current_month
    , case when week_days_in_current_month > 7 then 0 else 7 - week_days_in_current_month end as week_days_in_other_month
    , DAYOFYEAR(MY_DATE) as day_of_year
    , CONCAT(MONTH(MY_DATE), '-', DAY(MY_DATE)) as day_month
    , google_sheets.sales_seasons.season as sales_season
    , TO_CHAR(MY_DATE,'Mon YYYY') as posting_period 
FROM CTE_MY_DATE
LEFT JOIN google_sheets.sales_seasons on day_month = google_sheets.sales_seasons.date