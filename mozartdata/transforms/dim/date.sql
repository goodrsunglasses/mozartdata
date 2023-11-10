WITH CTE_MY_DATE AS (
    SELECT DATEADD(DAY, SEQ4(), '2000-01-01') AS MY_DATE
    FROM TABLE(GENERATOR(ROWCOUNT=>100000))
)
SELECT MY_DATE as date_timestamp
    , date(MY_DATE) as date
    , TO_CHAR(MY_DATE, 'YYYYMMDD')::int as date_int
    , YEAR(MY_DATE) as year
    , MONTH(MY_DATE) as month
    , MONTHNAME(MY_DATE) as month_name
    , DAY(MY_DATE) as day
    , DAYOFWEEK(MY_DATE) as day_of_week
    , WEEKOFYEAR(MY_DATE) as week_of_year
    , DAYOFYEAR(MY_DATE) as day_of_year
    , CONCAT(MONTH(MY_DATE), '-', DAY(MY_DATE)) as day_month
    , google_sheets.sales_seasons.season as sales_season
    , TO_CHAR(MY_DATE,'Mon YYYY') as posting_period 
FROM CTE_MY_DATE
LEFT JOIN google_sheets.sales_seasons on day_month = google_sheets.sales_seasons.date