with events as
  (
    SELECT
      *
    from
      fact.klaviyo_events e
    where
      e.event_date between '2024-01-01' and '2025-01-30'
  )

SELECT
  date_trunc('month',e.event_date) event_month
, count(distinct case when e.metric_name = 'Opened Email' then e.profile_id_klaviyo else null end) as opened_count
, count(distinct case when e.machine_open_flag then e.profile_id_klaviyo else null end) as machine_opened_count
, count(distinct case when e.machine_open_flag and e.metric_name = 'Opened Email' then e.profile_id_klaviyo else null end) as machine_and_human_opened_count
, count(distinct case when e.metric_name = 'Clicked Email' then e.profile_id_klaviyo else null end) as clicked_count
, count(distinct case when e.metric_name ='Received Email' then e.profile_id_klaviyo else null end) as received_count
, div0(opened_count,received_count) as open_rate
, div0(clicked_count/received_count) as click_thru_rate
from
  events e
where
  e.event_date between '2024-01-01' and '2025-01-30'
group by all
order by 1
