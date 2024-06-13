SELECT
    camp_s.id
    , DATE_TRUNC('WEEK',
        DATEADD('DAY',
            MOD(
                FLOOR(
                    DATEDIFF('DAY', '2023-12-31'::date, date_trunc('week', camp_s.date))
                / 7)
            , 2)
        * -7, camp_s.date)
    ) as period_start
    , 'WEEKS ' || WEEKOFYEAR(period_start) || '/' || WEEKOFYEAR(DATEADD('week', 1, period_start)) as week_nums
    , camp_s.date
    , camp_info.g_ads_campaign_id
    , camp_info.name
    , round(sum(camp_s.conversions_value), 2) AS revenue
    , round(sum(camp_s.cost_micros) / 1000000, 2) AS spend
    , sum(camp_s.clicks) AS clicks
    , round(sum(camp_s.conversions), 2) AS conversions
    , sum(camp_s.impressions) AS impressions
FROM
    google_ads_us.campaign_stats AS camp_s
INNER JOIN
    dim.google_ads_campaign_names AS camp_info
on
  camp_s.id = camp_info.g_ads_campaign_id
where
    camp_s.date >= '2023-12-31'
GROUP BY
    camp_s.id
    , camp_info.g_ads_campaign_id
    , camp_info.name
    , camp_s.date
ORDER BY
    camp_s.date asc
    , camp_info.name asc