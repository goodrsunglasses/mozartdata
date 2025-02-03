/**
 * This function generates a summary report of marketing campaign performance across various social channels.
 * The report includes metrics such as clicks, conversions, impressions, revenue, and spend.
 *
 * @return {table} A table containing the following columns:
 * - date: The date of the report.
 * - week_of_year: The week number of the year.
 * - media_period_start_date: The start date of the media period.
 * - media_period_end_date: The end date of the media period.
 * - media_week_label: The label for the media week.
 * - social_channel: The social channel for the campaign.
 * - marketing_strategy: The marketing strategy for the campaign.
 * - clicks: The total number of clicks for the campaign.
 * - conversions: The total number of conversions for the campaign.
 * - impressions: The total number of impressions for the campaign.
 * - revenue: The total revenue generated by the campaign.
 * - spend: The total amount spent on the campaign.
 */
with
    tiktok as
        (
            select
                tmd.event_date
              , 'tiktok'             as social_channel
              , 'USA'                as account_country
              , case
                    when tc.funnel_stage in ('TOF', 'MOF')
                        then 'Awareness'
                    when tc.funnel_stage in ('BOF')
                        then 'Performance'
                    else 'Other'
                end                  as marketing_strategy
              , sum(tmd.spend)       as spend
              , sum(tmd.revenue)     as revenue
              , sum(tmd.impressions) as impressions
              , sum(tmd.clicks)      as clicks
              , sum(tmd.conversions) as conversions
            from
                fact.tiktok_campaign_metrics_daily tmd
                inner join
                    dim.tiktok_campaigns           tc
                        on tmd.campaign_id_tiktok = tc.campaign_id_tiktok
            where
                tc.funnel_stage in ('TOF', 'MOF', 'BOF')
            group by
                tmd.event_date
              , tc.funnel_stage
        )
  , g_ads as
        (
            select
                ga.date      as event_date
              , 'google ads' as social_channel
              , case
                    when lower(ga.account_name) = 'goodr canada'
                        then 'CAN'
                    when lower(ga.account_name) = 'goodr sunglasses'
                        then 'USA'
                    else 'Other'
                end          as account_country
              , case
                    when ga.funnel_stage not in ('Awareness', 'Performance')
                        then 'Other'
                    else ga.funnel_stage
                end          as marketing_strategy
              , ga.spend
              , ga.revenue
              , ga.impressions
              , ga.clicks
              , ga.conversions
            from
                fact.google_ads_daily_stats ga
        )
  , snap_ads as (
            select
                scmd.report_date            as event_date
              , 'snapchat'                  as social_channel
              , 'USA'                       as account_country
              , scmd.marketing_strategy
              , round(sum(scmd.spend), 2)   as spend
              , round(sum(scmd.revenue), 2) as revenue
              , sum(scmd.impressions)       as impressions
              , sum(scmd.clicks)            as clicks
              , sum(scmd.conversions)       as conversions
            from
                fact.snapchat_campaign_metrics_daily scmd
            where
                scmd.funnel_stage in ('TOF', 'MOF', 'BOF')
            group by
                scmd.report_date
              , scmd.marketing_strategy
        )
  , meta_ads as (
            select
                macmd.date                    as event_date
              , 'meta'                        as social_channel
              , case
                    when lower(mc.account_name) = 'goodr canada'
                        then 'CAN'
                    when lower(mc.account_name) = 'goodr'
                        then 'USA'
                    else 'Other'
                end                           as account_country
              , mc.media_strategy             as marketing_strategy
              , round(sum(macmd.spend), 2)    as spend
              , round(sum(macmd.revenue), 2)  as revenue
              , sum(macmd.impressions)        as impressions
              , sum(macmd.inline_link_clicks) as clicks
              , sum(macmd.conversions)        as conversions
            from
                dim.meta_campaigns                       mc
                inner join
                    fact.meta_ads_campaign_metrics_daily macmd
                        on mc.campaign_id_meta = macmd.campaign_id_meta
            where
                mc.funnel_stage in ('TOF', 'MOF', 'BOF')
            group by
                macmd.date
              , mc.account_name
              , mc.media_strategy
        )
  , combined as
        (
            select
                *
            from
                tiktok
            union all
            select
                *
            from
                g_ads
            union all
            select
                *
            from
                snap_ads
            union all
            select
                *
            from
                meta_ads
        ), pre_to_date as
  (
select
    d.date
  , d.week_of_year
  , d.month
  , d.year
  , d.sales_season
  , d.media_period_start_date
  , d.media_period_end_date
  , d.media_period_label
  , c.social_channel
  , c.account_country
  , c.marketing_strategy
  , sum(c.spend)       as spend
  , sum(c.revenue)     as revenue
  , sum(c.impressions) as impressions
  , sum(c.clicks)      as clicks
  , sum(c.conversions) as conversions


from
    dim.date     d
    left join
        combined c
            on c.event_date = d.date
where
      d.week_year >= 2024
  and d.date <= current_date()
group by
    d.date
  , d.week_of_year
  , d.month
  , d.sales_season
  , d.year
  , d.media_period_start_date
  , d.media_period_end_date
  , d.media_period_label
  , c.social_channel
  , c.account_country
  , c.marketing_strategy)
SELECT
    p.date
  , p.week_of_year
  , p.month
  , p.year
  , p.sales_season
  , p.media_period_start_date
  , p.media_period_end_date
  , p.media_period_label
  , p.social_channel
  , p.account_country
  , p.marketing_strategy
  , p.spend
  , p.revenue
  , p.impressions
  , p.clicks
  , p.conversions
  , sum(spend) over  (partition by sales_season, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) spend_season_to_date
  , sum(revenue) over  (partition by sales_season, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) revenue_season_to_date
  , sum(impressions) over  (partition by sales_season, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) impressions_season_to_date
  , sum(clicks) over  (partition by sales_season, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) clicks_season_to_date
  , sum(conversions) over  (partition by sales_season, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) conversions_season_to_date
  , sum(spend) over  (partition by month, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) spend_month_to_date
  , sum(revenue) over  (partition by month, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) revenue_month_to_date
  , sum(impressions) over  (partition by month, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) impressions_month_to_date
  , sum(clicks) over  (partition by month, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) clicks_month_to_date
  , sum(conversions) over  (partition by month, social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) conversions_month_to_date
  , sum(spend) over  (partition by social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) spend_year_to_date
  , sum(revenue) over  (partition by social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) revenue_year_to_date
  , sum(impressions) over  (partition by social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) impressions_year_to_date
  , sum(clicks) over  (partition by social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) clicks_year_to_date
  , sum(conversions) over  (partition by social_channel, account_country, marketing_strategy, year ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) conversions_year_to_date

FROM
  pre_to_date p
WHERE p.year = 2025