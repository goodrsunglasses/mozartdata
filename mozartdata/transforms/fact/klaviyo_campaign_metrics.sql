with campaigns as
  (
  SELECT
    ke.campaign_id_klaviyo
  , kc.name as campaign_name
  , kc.send_date
  , kc.send_date_pst
  , kc.scheduled_date
  , sum(case when ke.metric_name in ('Received Email','Bounced Email') then 1 else 0 end) as email_sent
  , sum(case when ke.metric_name = 'Received Email' then 1 else 0 end) as email_delivered
  , sum(case when ke.metric_name = 'Bounced Email' then 1 else 0 end) as email_bounced
  , sum(case when ke.metric_name = 'Marked Email as Spam' then 1 else 0 end) as email_spam_complaint
  , sum(case when ke.metric_name = 'Opened Email' then 1 else 0 end) as email_opened
  , count(distinct case when ke.metric_name = 'Opened Email' then ke.profile_id_klaviyo end) unique_opened
  , sum(case when ke.metric_name = 'Clicked Email' then 1 else 0 end) as email_clicked
  , count(distinct case when ke.metric_name = 'Clicked Email' then ke.profile_id_klaviyo end) unique_clicked
  , sum(case when ke.metric_name = 'Unsubscribed' then 1 else 0 end) as email_unsubscribed
  FROM
    fact.klaviyo_events ke
  INNER JOIN
    dim.klaviyo_campaigns kc
    on ke.campaign_id_klaviyo = kc.campaign_id_klaviyo
  GROUP BY
    ke.campaign_id_klaviyo
  , kc.name
  , kc.send_date
  , kc.send_date_pst
  , kc.scheduled_date
)
,
campaign_profiles as
(
  SELECT DISTINCT
    ke.campaign_id_klaviyo
  , kc.name as campaign_name 
  , kc.send_date
  , ke.profile_id_klaviyo
  FROM
    fact.klaviyo_events ke
  INNER JOIN
    dim.klaviyo_campaigns kc
    on ke.campaign_id_klaviyo = kc.campaign_id_klaviyo
  WHERE
    ke.metric_name = 'Received Email'
), orders as
(
  SELECT
    o.campaign_id_klaviyo
  , o.campaign_name
  , o.flow_id_klaviyo
  , o.flow_name
  , count(o.order_id_shopify) as order_count 
  , count(distinct o.profile_id_klaviyo) as unique_profile_count  
  , sum(o.total_amount) as total_amount
  , sum(o.subtotal_amount) as subtotal_amount
  FROM
    fact.klaviyo_order_attribution o
  WHERE
    o.klaviyo_attribution_flag = true
  GROUP BY
      o.campaign_id_klaviyo
  , o.campaign_name
  , o.flow_id_klaviyo
  , o.flow_name
)
SELECT
  c.*
, o.*
FROM
  campaigns c
left join
  fact.klaviyo_order_attribution o
  on c.campaign_id_klaviyo = o.campaign_id_klaviyo
  and o.klaviyo_order_attribution = true

-- select
-- *
-- FROM
-- klaviyo_portable.klaviyo_v2_campaigns_8589937320
-- where name = 'D2C 2/16 St Patrick''s Day Launch'