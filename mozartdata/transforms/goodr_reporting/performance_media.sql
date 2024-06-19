WITH
  tiktok   AS
    (
      SELECT
        tmd.event_date
      , 'tiktok'             AS social_channel
      , CASE
          WHEN tc.funnel_stage IN ('TOF', 'MOF') THEN 'Awareness'
          WHEN tc.funnel_stage IN ('BOF') THEN 'Performance'
          ELSE 'Other' END   AS marketing_strategy
      , SUM(tmd.spend)       AS spend
      , SUM(tmd.revenue)     AS revenue
      , SUM(tmd.impressions) AS impressions
      , SUM(tmd.clicks)      AS clicks
      , SUM(tmd.conversions) AS conversions
      FROM
        fact.tiktok_campaign_metrics_daily tmd
        INNER JOIN
          dim.tiktok_campaigns tc
          ON tmd.campaign_id_tiktok = tc.campaign_id_tiktok
      WHERE
        tc.funnel_stage IN ('TOF', 'MOF', 'BOF')
      GROUP BY
        tmd.event_date
      , tc.funnel_stage
      )
, g_ads    AS
    (
      SELECT
        ga.date         AS event_date
      , 'google ads'    AS social_channel
      , case when ga.funnel_stage not in ('Awareness','Performance') then 'Other' else ga.funnel_stage end AS marketing_strategy
      , ga.spend
      , ga.revenue
      , ga.impressions
      , ga.clicks
      , ga.conversions
      FROM
        fact.google_ads_daily_stats ga
      )
, combined AS
    (
      SELECT *
      FROM
        tiktok
      UNION ALL
      SELECT *
      FROM
        g_ads
      )
SELECT
  d.date
, d.week_of_year
, d.media_period_start_date
, d.media_period_end_date
, d.media_week_label
, c.social_channel
, c.marketing_strategy
, SUM(c.clicks)      AS clicks
, SUM(c.conversions) AS conversions
, SUM(c.impressions) AS impressions
, SUM(c.revenue)     AS revenue
, SUM(c.spend)       AS spend
FROM
  dim.date d
  LEFT JOIN
    combined c
    ON c.event_date = d.date
WHERE
  d.week_year >= 2024
GROUP BY
  d.date
, d.week_of_year
, d.media_period_start_date
, d.media_period_end_date
, d.media_week_label
, c.social_channel
, c.marketing_strategy