/*
Purpose: This table contains all KPIs for Klaviyo Campaigns.
Note: This data does not always perfectly tie to what you see in Klaviyo for a few reasons.
1) The time the EDW updates compared to when you look at Klaviyo can result in different numbers.
2) There are variances between spam and unsubscribe counts. The root cause is unknown, but the variances are generally

Transforms: This script is broken down into 2 CTES, one to capture campaign KPI data, and another for order attribution.
The final query combines campaigns and orders into a single result which shows all KPIs per campaign.
*/
with campaigns as
  (
  SELECT
    ke.campaign_id_klaviyo
  , kc.name as campaign_name
  , kc.send_date
  , kc.send_date_pst
  , kc.scheduled_date
  , sum(case when ke.metric_name in ('Received Email','Bounced Email') then 1 else 0 end) as sent_count
  , sum(case when ke.metric_name = 'Received Email' then 1 else 0 end) as delivered_count
  , sum(case when ke.metric_name = 'Bounced Email' then 1 else 0 end) as bounced_count
  , sum(case when ke.metric_name = 'Marked Email as Spam' then 1 else 0 end) as spam_complaint_count
  , sum(case when ke.metric_name = 'Opened Email' then 1 else 0 end) as opened_count
  , count(distinct case when ke.metric_name = 'Opened Email' then ke.profile_id_klaviyo end) unique_opened_count
  , sum(case when ke.metric_name = 'Clicked Email' then 1 else 0 end) as clicked_count
  , count(distinct case when ke.metric_name = 'Clicked Email' then ke.profile_id_klaviyo end) unique_clicked_count
  , sum(case when ke.metric_name = 'Unsubscribed' then 1 else 0 end) as unsubscribed_count
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
  GROUP BY
      o.campaign_id_klaviyo
  , o.campaign_name
  , o.flow_id_klaviyo
  , o.flow_name
)
SELECT
    c.campaign_id_klaviyo
  , c.campaign_name
  , c.send_date
  , c.scheduled_date
  , c.sent_count
  , c.delivered_count
  , c.bounced_count
  , c.spam_complaint_count
  , c.unsubscribed_count
  , c.opened_count
  , c.unique_opened_count
  , c.clicked_count
  , c.unique_clicked_count
  , o.order_count
  , o.unique_profile_count as unique_order_count
  , o.total_amount
  , o.subtotal_amount
  , case when c.delivered_count = 0 then 0 else c.unique_opened_count/c.delivered_count end as open_rate
  , case when c.delivered_count = 0 then 0 else c.unique_clicked_count/c.delivered_count end as click_rate
  , case when c.delivered_count = 0 then 0 else o.unique_profile_count/c.delivered_count end as conversion_rate
  , case when o.order_count = 0 then 0 else o.total_amount/o.order_count end as aov 
FROM
  campaigns c
LEFT JOIN
  orders o
  on c.campaign_id_klaviyo = o.campaign_id_klaviyo
WHERE
  c.send_date >= '2024-01-01' or c.send_date is null--events data only goes back to 2024. So we don't want to pull in incomplete metrics for campaigns which started prior to 2024