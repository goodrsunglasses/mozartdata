with awareness_weeks_cte as (
        SELECT
            period_start
            , dateadd('day', 13, period_start) as period_end
            --,campaign_name
            , week_nums
            , round(sum(revenue), 2)::number(15, 2) as revenue
            , round(sum(spend), 2)::number(15, 2) as spend
            , sum(clicks) as clicks
            , sum(impressions) as impressions
            , round(sum(spend) / sum(clicks), 2) as CPC
            , round(sum(clicks)/sum(impressions), 4) as CTR
            , round(sum(spend)/(sum(impressions)/1000), 2) as CPM
            , CASE
                WHEN LAG(sum(spend), 1, 0) over (order by period_start) != 0
                THEN round((sum(spend) / LAG(sum(spend), 1) over (order by period_start) - 1), 3)
                ELSE null
            END as WoW_spend_pct_change
            , CASE
                WHEN LAG(sum(clicks), 1, 0) over (order by period_start) != 0
                THEN round((sum(clicks) / LAG(sum(clicks), 1) over (order by period_start) - 1), 3)
                ELSE null
            END as WoW_clicks_pct_change
            , CASE
                WHEN LAG(sum(impressions), 1, 0) over (order by period_start) != 0
                THEN round((sum(impressions) / LAG(sum(impressions), 1) over (order by period_start) - 1), 3)
                ELSE null
            END as WoW_impressions_pct_change
            , CASE
                WHEN
                    LAG(sum(spend), 1, 0) over (order by period_start) != 0
                    AND LAG(sum(clicks), 1, 0) over (order by period_start) != 0
                THEN
                    round(((sum(spend) / sum(clicks)) /
                    (
                        LAG(sum(spend), 1) over (order by period_start) /
                        LAG(sum(clicks), 1) over (order by period_start)
                    )- 1), 3)
                ELSE null
            END as WoW_CPC_pct_change
            , CASE
                WHEN
                    LAG(sum(clicks), 1, 0) over (order by period_start) != 0
                    AND LAG(sum(impressions), 1, 0) over (order by period_start) != 0
                THEN
                    round(((sum(clicks) / sum(impressions)) /
                    (
                        LAG(sum(clicks), 1) over (order by period_start) /
                        LAG(sum(impressions), 1) over (order by period_start)
                    )- 1), 3)
                ELSE null
            END as WoW_CTR_pct_change
            , CASE
                WHEN
                    LAG(sum(spend), 1, 0) over (order by period_start) != 0
                    AND LAG(sum(impressions), 1, 0) over (order by period_start) != 0
                THEN
                    round(((sum(spend) / sum(impressions)) * 1000 /
                    (
                        LAG(sum(spend), 1) over (order by period_start) * 1000 /
                        LAG(sum(impressions), 1) over (order by period_start)
                    ) - 1), 3)
                ELSE null
            END as WoW_CPM_pct_change
        from
            fact.google_ads_campaigns_daily_stats aware_d
        where
            period_start >= '2023-12-31'
            and period_end <= CURRENT_DATE
            and (
                campaign_name like '%TOF%'
                or campaign_name like '%MOF%'
            )
            --period_start = '2024-04-07'
        group by
            period_start
            ,week_nums
            --,campaign_name
        order by
            period_start
            --conversions
    )

    , seas_end_date_cte as (
        select
            sales_season
            , year
            , max(date) as season_end
        from
            dim.date
        where
            date >= '2024-01-01'
        group by
            year
            , sales_season
    )


    , aware_prev_month_seas_year_cte as (
        select distinct
            camp_d.period_start
            , dateadd('day', 13, camp_d.period_start) as period_end
            --, camp_d.date
            --, camp_d.campaign_name
            , seas.sales_season
            , case
                when seas.sales_season = 'Valley' then 1
                when seas.sales_season = 'Climb' then 2
                when seas.sales_season = 'Peak' then 3
                when seas.sales_season = 'Dip' then 4
                when seas.sales_season = 'Spike' then 5
            end as seas_num
            , seas_end.season_end
            , month(camp_d.date) as month
            , year(camp_d.date) as year
            , round(mon_totals.spend, 2) as prev_month_spend
            , mon_totals.clicks as prev_month_clicks
            , mon_totals.impressions as prev_month_impressions
            , mon_totals.CPC as prev_month_CPC
            , mon_totals.CTR as prev_month_CTR
            , mon_totals.CPM as prev_month_CPM
            , sum(camp_d.revenue) over (
                partition by seas.sales_season
                order by camp_d.period_start asc
            ) as season_revenue
            , round(sum(camp_d.spend) over (
                partition by seas.sales_season
                order by camp_d.period_start asc
            ), 2) as season_spend
            , sum(camp_d.clicks) over (
                partition by seas.sales_season
                order by camp_d.period_start asc
            ) as season_clicks
            , sum(camp_d.impressions) over (
                partition by seas.sales_season
                order by camp_d.period_start asc
            ) as season_impressions
            , round(season_spend / season_clicks, 2) as season_CPC
            , round(season_clicks / season_impressions, 2) as season_CTR
            , round(season_spend * 1000 / season_impressions, 2) as season_CPM
            , sum(camp_d.revenue) over (
                partition by month(camp_d.date), year(camp_d.date)
                order by camp_d.period_start asc
            ) as month_revenue,
            round(sum(camp_d.spend) over (
                partition by year(camp_d.date)
                order by camp_d.period_start asc
            ), 2) as year_spend
            , sum(camp_d.clicks) over (
                partition by year(camp_d.date)
                order by camp_d.period_start asc
            ) as year_clicks, sum(camp_d.impressions) over (
                partition by year(camp_d.date)
                order by camp_d.period_start asc
            ) as year_impressions
            , round(year_spend / year_clicks, 2) as year_CPC
            , round(year_clicks / year_impressions, 2) as year_CTR
            , round(year_spend * 1000 / year_impressions, 2) as year_CPM
            --, sum(revenue) over (partition by period_start, camp_d.campaign_name order by period_start asc) as revenue
        from
            fact.google_ads_campaigns_daily_stats as camp_d
        left join
            dim.date AS seas
            on
                camp_d.date = seas.date
        left join
            fact.google_ads_campaigns_monthly_stats as mon_totals
            on
                mon_totals.month = month(dateadd('day', -1, date_trunc('month', camp_d.date)))
                and mon_totals.year = year(dateadd('day', -1, date_trunc('month', camp_d.date)))
        left join
            seas_end_date_cte as seas_end
            on
                seas_end.sales_season = seas.sales_season
                and seas_end.year = year(camp_d.date)
        where
            year(camp_d.date) >= 2024
            and (
                camp_d.campaign_name like '%TOF%'
                or camp_d.campaign_name like '%MOF%'
            )
            and (
                mon_totals.campaign_name like '%TOF%'
                or mon_totals.campaign_name like '%MOF%'
            )
        order by
            camp_d.period_start asc
            , month asc
    )

    , aware_prev_month_seas_year_stg2_cte as (
        select
            period_start
            , period_end
            , prev_month_spend
            , season_spend
            , year_spend
            , prev_month_clicks
            , season_clicks
            , year_clicks
            , prev_month_impressions
            , season_impressions
            , year_impressions
            , prev_month_CPC
            , season_CPC
            , year_CPC
            , prev_month_CTR
            , season_CTR
            , year_CTR
            , prev_month_CPM
            , season_CPM
            , year_CPM
        from
            aware_prev_month_seas_year_cte
        where
            seas_num is not null
        qualify
            ROW_NUMBER() OVER (
                PARTITION BY period_start
                ORDER BY
                    case
                        when day(period_end) < 4 and period_end > season_end then season_revenue
                        when day(period_end) < 4 and period_end < season_end then month_revenue
                        else seas_num
                    end desc
                    , year desc
                    , month desc
            ) = 1
    )

    select
        weeks.period_start
        , weeks.period_end
        , weeks.week_nums
        , weeks.spend
        , weeks.clicks
        , weeks.impressions
        , weeks.CPC
        , weeks.CTR
        , weeks.CPM
        , weeks.WoW_spend_pct_change
        , weeks.WoW_clicks_pct_change
        , weeks.WoW_impressions_pct_change
        , weeks.WoW_CPC_pct_change
        , weeks.WoW_CTR_pct_change
        , weeks.WoW_CPM_pct_change
        , seas.prev_month_spend
        , seas.season_spend
        , seas.year_spend
        , seas.prev_month_clicks
        , seas.season_clicks
        , seas.year_clicks
        , seas.prev_month_impressions
        , seas.season_impressions
        , seas.year_impressions
        , seas.prev_month_CPC
        , seas.season_CPC
        , seas.year_CPC
        , seas.prev_month_CTR
        , seas.season_CTR
        , seas.year_CTR
        , seas.prev_month_CPm
        , seas.season_CPM
        , seas.year_CPM
    from
        awareness_weeks_cte as weeks
    left join
        aware_prev_month_seas_year_stg2_cte as seas
        on weeks.period_start = seas.period_start