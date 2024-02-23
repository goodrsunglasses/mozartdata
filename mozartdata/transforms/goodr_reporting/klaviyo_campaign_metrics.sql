SELECT
  ke.campaign_id_klaviyo
, sum(case when ke.metric_name = 'Bounced Email' then 1 else 0 end) as email_bounced
, sum(case when ke.metric_name = 'Clicked Email' then 1 else 0 end) as email_clicked
, sum(case when ke.metric_name = 'Opened Email' then 1 else 0 end) as email_opened
, sum(case when ke.metric_name = 'Received Email' then 1 else 0 end) as email_delivered
, sum(case when ke.metric_name in ('Received Email','Bounced Email') then 1 else 0 end) as email_send
FROM
  fact.klaviyo_events ke
GROUP BY
  ke.campaign_id_klaviyo