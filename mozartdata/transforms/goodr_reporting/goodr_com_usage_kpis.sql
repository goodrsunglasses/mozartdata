with sessions_cte as (
     select
         ses.date
       , ses.session_default_channel_grouping as channel_group
       , sum(zeroifnull(ses.sessions))        as total_sessions
     from
         google_analytics_4.traffic_acquisition_session_default_channel_grouping as ses
     where
         ses.property = 'properties/353637527'
     group by
         ses.date
       , channel_group
     order by
         ses.date desc
)

, conversions_cte as (
    select
        e.date
        , sum(e.total_users) as total_conversions
    from
        google_analytics_4.events as e
    where
        property = 'properties/353637527'
        and lower(event_name) = 'purchase'
    group by
        e.date
    order by
        date desc
)

select
    s.date
    , s.total_sessions
    , c.total_conversions
    , round((c.total_conversions / s.total_sessions), 2) as conv_rate
from
    sessions_cte as s
left join
    conversions_cte as c
