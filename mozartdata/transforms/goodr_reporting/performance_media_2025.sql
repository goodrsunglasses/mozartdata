/*
  This report feeds the 2025 Performance Media google sheet

 */
SELECT 
  date
, week_of_year
, month
, year
, sales_season
, media_period_start_date
, media_period_end_date
, media_period_label
, social_channel
, account_country
, marketing_strategy
, funnel_stage
, spend
, revenue
, impressions
, clicks
, conversions
, spend_season_to_date
, revenue_season_to_date
, impressions_season_to_date
, clicks_season_to_date
, conversions_season_to_date
, spend_month_to_date
, revenue_month_to_date
, impressions_month_to_date
, clicks_month_to_date
, conversions_month_to_date
, spend_year_to_date
, revenue_year_to_date
, impressions_year_to_date
, clicks_year_to_date
, conversions_year_to_date
FROM
  goodr_reporting.performance_media
WHERE
  year = 2025