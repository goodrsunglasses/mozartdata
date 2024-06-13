select
    g_ads_campaign_id
    , name
    , month(date) as month
    , year(date) as year
    , round(sum(revenue), 2) as revenue
    , round(sum(spend), 2) as spend
    , sum(clicks) as clicks
    , round(sum(conversions), 2) as conversions
    , sum(impressions) as impressions
    , case
        when sum(clicks) != 0
        then round(sum(spend) / sum(clicks), 2)
        else 0
    end as CPC
    , case
        when sum(impressions) != 0
        then round(sum(clicks)/sum(impressions), 4)
        else 0
    end as CTR
    , case
        when sum(spend) != 0
        then round(sum(revenue)/sum(spend), 2)
        else 0
    end as ROAS
    , case
        when sum(conversions) != 0
        then round(sum(spend)/sum(conversions), 2)
        else 0
    end as CPA
    , case
        when sum(clicks) != 0
        then round(sum(conversions)/sum(clicks), 4)
        else 0
    end as CVR
    , case
        when sum(impressions) != 0
        then round(sum(spend) * 1000 /sum(impressions), 2)
        else 0
    end as CPM
from
    fact.google_ads_campaigns_daily_stats as camp_d
group by
    g_ads_campaign_id
    , name
    , month(camp_d.date)
    , year(camp_d.date)