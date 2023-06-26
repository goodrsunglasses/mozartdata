-- Step 1. Generate a date spine starting from January 1st, 1990 up to 50 years in the future.

WITH date_spine AS (
  SELECT
    dateadd('day', seq4(), '1990-01-01':: DATE):: DATE AS the_date
  FROM
    TABLE (generator(rowcount => 100000))
  WHERE
    the_date <= dateadd('year', 50, CURRENT_DATE())
),

-- Step 2. Generate various date parts and other metrics for each date in the previous date_spine CTE.

date_map AS (
  SELECT
    -- dates
    the_date AS "date",
    -- for backwards compatibility
    the_date,
    dateadd('day', -1, the_date) AS lag_date,
    dateadd('week', -1, the_date) AS lag_week,
    dateadd('month', -1, the_date) AS lag_month,
    dateadd('year', -1, the_date) AS lag_year,
    date_trunc('week', the_date) AS datepart_firstdayofweek,
    date_trunc('month', the_date) AS datepart_firstdayofmonth,
    date_trunc('year', the_date) AS datepart_firstdayofyear,
    last_day(the_date, 'week') AS eow,
    last_day(the_date, 'month') AS eom,
    last_day(the_date, 'quarter') AS eoq,
    last_day(the_date, 'year') AS eoy,
    -- numbers
    date_part('year', the_date) AS the_year,
    date_part('month', the_date) AS the_month,
    date_part('day', the_date) AS dom,
    date_part('doy', the_date) AS doy,
    date_part('dow_iso', the_date) AS dow,
    date_part('week', the_date) AS the_week,
    date_part('quarter', the_date) AS the_quarter,
    -- bools
    CASE WHEN the_date = current_date() THEN TRUE ELSE FALSE END AS is_latest_date,
    CASE WHEN the_date > current_date() THEN TRUE ELSE FALSE END AS is_future_date,
    CASE WHEN date_part('dow_iso', the_date) < 6 THEN TRUE ELSE FALSE END AS is_weekday,
    CASE WHEN the_date = last_day(the_date, 'week') THEN TRUE ELSE FALSE END AS is_eow,
    CASE WHEN the_date = last_day(the_date, 'month') THEN TRUE ELSE FALSE END AS is_eom,
    CASE WHEN the_date = last_day(the_date, 'quarter') THEN TRUE ELSE FALSE END AS is_eoq,
    CASE WHEN the_date = last_day(the_date, 'year') THEN TRUE ELSE FALSE END AS is_eoy,
    CASE WHEN date_part('year', the_date) % 4 = 0 THEN TRUE ELSE FALSE END AS is_leap_year,
    NULL AS is_holiday,
    NULL AS is_mozart_holiday,
   -- names
  dayname(the_date) AS day_name,
  monthname(the_date) AS the_monthname,
  null AS holiday_name
FROM 
  date_spine
),


-- Step 3. Generate a series of dates between the current date and 13 days ago, along with various metrics for each date.

dates as (
  SELECT datediff(day, the_date, (SELECT MAX(processed_timestamp) from mz_reporting_shopify.orders) :: date),
        *
FROM 
  date_map
WHERE 
  datediff(day, the_date, (SELECT MAX(processed_timestamp) from mz_reporting_shopify.orders) :: date) BETWEEN 0 AND 13
),

-- Step 4. Join the filtered dates with the orders table to get the total sales for each date, as well as the week number and day of the week.

filtered AS (
  SELECT d.the_date, 
        CEIL((((SELECT MAX(processed_timestamp) FROM mz_reporting_shopify.orders) :: date) - d.the_date + 1)/7) AS weeks_ago,
        MOD((((SELECT MAX(processed_timestamp) FROM mz_reporting_shopify.orders) :: date) - d.the_date), 7) AS day_in_week,
        so.* 
  FROM 
    dates AS d
  LEFT JOIN mz_reporting_shopify.orders AS so ON d.the_date = so.processed_timestamp

  ORDER BY
    d.the_date DESC
),

-- Step 5.  Calculate the total sales for each day of the week over the past 2 weeks, grouped by week number and day of the week.
aggregated AS (
  SELECT the_date,
        weeks_ago,
        day_in_week,
        coalesce(sum(total_line_items_price), 0) AS day_total
  FROM
    filtered
  GROUP BY 
    the_date,
    weeks_ago,
    day_in_week
),

-- Step 6. Calculate the total sales from the same day of the week one week ago for each day in the past week for week-over-week comparisons.

lagged AS (
  SELECT *,
    LAG(day_total, 1, 0) OVER(PARTITION BY day_in_week ORDER BY weeks_ago DESC) AS last_week
  FROM
    aggregated
  ORDER BY
    the_date DESC
)

-- Step 7. Select all columns from the `lagged` CTE where the week number is exactly 1, or the results from the past week.

  SELECT *
  FROM
    lagged
  WHERE
    weeks_ago = 1