/*
 Purpose: to extract and transform data from the TIKTOK_ADS.CAMPAIGN_HISTORY table.
-- It selects distinct campaign IDs, names, funnel stages, campaign strategies, media strategies,
-- campaign types, budget modes, operation statuses, objective types, create times, and create dates.
-- The funnel stages, campaign strategies, and media strategies are determined based on specific patterns in the campaign names.
-- The query is ordered by campaign ID.

-- Used downstream in the tiktok_ads_daily_stats table primarily

 One row per tiktok campaign id
Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with root_table as (
    select
      *
    from
      mozart.pipeline_root_table
)
select distinct
    ch.campaign_id       as campaign_id_tiktok
  , ch.campaign_name
  , case
        when ch.campaign_name like '%TOF%'
            then 'TOF'
        when ch.campaign_name like '%MOF%'
            then 'MOF'
        when ch.campaign_name like '%BOF%'
            then 'BOF'
        else 'OTHER'
    end                  as funnel_stage
  , case
        when ch.campaign_name like '%TOF%'
            then 'Reach'
        when ch.campaign_name like '%MOF%'
            then 'Traffic, Engagement'
        when ch.campaign_name like '%BOF%'
            then 'Sales, Conversions'
        else 'Other'
    end                  as campaign_strategy
  , case
        when ch.campaign_name like '%TOF%'
            then 'Awareness'
        when ch.campaign_name like '%MOF%'
            then 'Awareness'
        when ch.campaign_name like '%BOF%'
            then 'Performance'
        else 'Other'
    end                  as media_strategy
  , ch.campaign_type
  , ch.budget_mode
  , ch.operation_status
  , ch.objective_type
  , ch.create_time
  , date(ch.create_time) as create_date
from
    tiktok_ads.campaign_history ch
qualify
  row_number() over (partition by campaign_id order by _fivetran_synced desc) = 1
order by
    ch.campaign_id