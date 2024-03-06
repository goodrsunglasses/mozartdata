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
  WHERE
    kc.name like 'D2C 2/16%'
  GROUP BY
    ke.campaign_id_klaviyo
  , kc.name
  , kc.send_date
  , kc.send_date_pst
  , kc.scheduled_date
),
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
),
orders as
(
SELECT
--   ke.event_date
-- , ke.profile_id_klaviyo
-- , ke.metric_name
  cp.campaign_id_klaviyo
, cp.campaign_name
, count(ke.event_id_klaviyo) order_count
, sum(ke.total_amount) total_amount
, sum(ke.subtotal_amount) subtotal_amount
FROM
  fact.klaviyo_events ke
LEFT JOIN
  campaign_profiles cp
  on ke.profile_id_klaviyo = cp.profile_id_klaviyo
  and ke.event_date between cp.send_date and dateadd(day,5,cp.send_date)
WHERE
  ke.metric_name = 'Placed Order'
GROUP BY
  cp.campaign_id_klaviyo
, cp.campaign_name
  
)
SELECT
  c.*
, o.order_count
, o.total_amount
, o.subtotal_amount
FROM
  campaigns c
left join
  orders o
  on c.campaign_id_klaviyo = o.campaign_id_klaviyo

-- select
-- *
-- FROM
-- klaviyo_portable.klaviyo_v2_campaigns_8589937320
-- where name = 'D2C 2/16 St Patrick''s Day Launch'