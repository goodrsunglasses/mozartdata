select
  bc.CAMPAIGN_ID as campaign_id_meta
, bc.CAMPAIGN_NAME as campaign_name
, bc.DATE as date
, bc.IMPRESSIONS as impressions
, bc.REACH as reach
, case when coalesce(bc.CPC,0) = 0 then 0 else round(bc.SPEND/bc.CPC) end as clicks
, coalesce(bc.INLINE_LINK_CLICKS,0) as inline_link_clicks
, bc.SPEND as spend
, coalesce(bc.COST_PER_INLINE_LINK_CLICK,0) as cpc_inline_link
, coalesce(bc.CPC,0) as cpc
, coalesce(bc.CPM,0) as cpm
, coalesce(bc.CTR,0) as ctr
, coalesce(bc.INLINE_LINK_CLICK_CTR,0) as ctr_inline_link
, bc.FREQUENCY as frequency
from
  FACEBOOK_ADS.BASIC_CAMPAIGN bc
order by
  bc.date desc
, bc.CAMPAIGN_ID asc