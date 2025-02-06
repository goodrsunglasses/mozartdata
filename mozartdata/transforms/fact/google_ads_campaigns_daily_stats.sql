select
    camp_info.campaign_id_g_ads
  , date_trunc('WEEK',
               dateadd('DAY',
                       mod(
                           floor(
                               datediff('DAY', '2023-12-31'::date, date_trunc('week', camp_s.date))
                                   / 7)
                           , 2)
                           * -7, camp_s.date)
    )                                                                                             as period_start
  , 'WEEKS ' || weekofyear(period_start) || ' / ' || weekofyear(dateadd('week', 1, period_start)) as week_nums
  , camp_s.date
  , camp_info.campaign_name
  , camp_info.account_id_g_ads
  , camp_info.account_name
  , sum(camp_s.conversions_value)                                                      as revenue
  , sum(camp_s.cost_micros) / 1000000                                                 as spend
  , sum(camp_s.clicks)                                                                            as clicks
  , sum(camp_s.conversions)                                                             as conversions
  , sum(camp_s.impressions)                                                                       as impressions
from
    google_ads_us.campaign_stats      as camp_s
    inner join
        dim.google_ads_campaign_names as camp_info
            on
            camp_s.id = camp_info.campaign_id_g_ads
group by
    camp_info.account_id_g_ads
  , camp_info.account_name
  , camp_info.campaign_id_g_ads
  , camp_info.campaign_name
  , camp_s.date
order by
    camp_s.date             asc
  , camp_info.campaign_name asc