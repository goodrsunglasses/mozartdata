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
orders as
(
SELECT
  ke.event_date
, ke.event_date_pst
, ke.event_properties
, ke.event_id_klaviyo
, ke.metric_name
, ke.order_id_shopify
, ke.total_amount
, ke.subtotal_amount
-- , sum(case when ke.metric_name in ('Ordered Product') then 1 else 0 end) as ordered_product
-- , sum(case when ke.metric_name = 'Placed Order' then 1 else 0 end) as placed_order
FROM
  fact.klaviyo_events ke
WHERE
  ke.metric_name in ('Ordered Product')
  and event_date = '2023-12-26'
  and JSON_EXTRACT_PATH_TEXT(ke.event_properties,'"$event_id"')::varchar like '5062089539642%'
GROUP BY
  ke.campaign_id_klaviyo
, ke.profile_id_klaviyo
-- , kc.name
-- , kc.send_date
-- , kc.send_date_pst
  
)
SELECT
  *
FROM
  campaigns c
left join
-- select distinct name from dim.klaviyo_metrics where name like '%Order%' order by name
select * from fact.klaviyo_events ke
  where ke.metric_name in ('Ordered Product','Placed Order')
SELECT
ke.metric_name
, count(*) total_count
, count(distinct profile_id_klaviyo) profile_count
FROM
fact.klaviyo_events ke
group by
ke.metric_name
order by 1

select
*
FROM
klaviyo_portable.klaviyo_v2_campaigns_8589937320
where name = 'D2C 2/16 St Patrick''s Day Launch'