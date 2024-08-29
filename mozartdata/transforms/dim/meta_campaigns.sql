-- This SQL script is used to retrieve campaign-related data from the Facebook Ads API.
-- It joins the campaign_history and account_history tables, applies case statements for categorizing
-- funnel stages, campaign strategies, and media strategies, and selects the most recent record for each campaign.

-- Used downstream in meta_ads_daily_stats and performance_media tables.

with
    account_cte as (
                       -- CTE to select distinct account IDs and names from the account_history table
                       select distinct
                           ah.id   as account_id_meta
                         , ah.name as account_name
                       from
                           facebook_ads.account_history ah
    )

select distinct
    ch.id                   as campaign_id_meta -- Unique identifier for the campaign
  , lower(ch.name)          as campaign_name -- Name of the campaign
  , ch.account_id           as account_id -- Account ID associated with the campaign
  , lower(acc.account_name) as account_name -- Name of the account
  , case
        when ch.name like '%TOF%'
            then 'TOF'
        when ch.name like '%MOF%'
            then 'MOF'
        when ch.name like '%BOF%'
            then 'BOF'
        else 'OTHER'
    end                     as funnel_stage -- Categorization of the campaign's funnel stage
  , case
        when ch.name like '%TOF%'
            then 'Reach'
        when ch.name like '%MOF%'
            then 'Traffic, Engagement'
        when ch.name like '%BOF%'
            then 'Sales, Conversions'
        else 'Other'
    end                     as campaign_strategy -- Categorization of the campaign's strategy
  , case
        when ch.name like '%TOF%'
            then 'Awareness'
        when ch.name like '%MOF%'
            then 'Awareness'
        when ch.name like '%BOF%'
            then 'Performance'
        else 'Other'
    end                     as media_strategy -- Categorization of the campaign's media strategy
  , ch.source_campaign_id   as parent_campaign_id_meta -- Identifier for the parent campaign
  , ch.configured_status -- Configured status of the campaign
  , ch.effective_status -- Effective status of the campaign
  , ch.bid_strategy -- Bid strategy used by the campaign
  , ch.buying_type -- Buying type of the campaign
  , ch.can_use_spend_cap -- Indicates whether the campaign has a spend cap
  , ch.daily_budget -- Daily budget of the campaign
  , ch.lifetime_budget -- Lifetime budget of the campaign
  , ch.objective -- Objective of the campaign
  , ch.smart_promotion_type -- Smart promotion type of the campaign
  , ch.created_time -- Time when the campaign was created
  , date(ch.created_time)   as created_date -- Date when the campaign was created
  , ch.start_time -- Time when the campaign started
  , date(ch.start_time)     as start_date -- Date when the campaign started
  , ch.stop_time -- Time when the campaign stopped
  , date(ch.stop_time)      as stop_date -- Date when the campaign stopped
from
    facebook_ads.campaign_history ch
    left join
        account_cte as            acc -- Join with the account_cte table on account_id
            on ch.account_id = acc.account_id_meta
qualify
    row_number() over (partition by ch.id order by ch.updated_time desc) = 1 -- Select the most recent record for each campaign
order by
    campaign_name asc; -- Sort the result by campaign name in ascending order