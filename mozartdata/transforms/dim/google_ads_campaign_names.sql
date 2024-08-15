with account_names as (
  select distinct 
    id
    , descriptive_name
  from
    google_ads_us.account_history
)

select distinct
  ch.id as campaign_id_g_ads
  , ch.name as campaign_name
  , an.id as account_id_g_ads
  , an.descriptive_name as account_name
FROM
  google_ads_us.campaign_history as ch
inner join
  account_names as an
  on 
    ch.customer_id = an.id