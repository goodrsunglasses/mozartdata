with period_map as (SELECT
'2024 V5'  as year,
  date,
  posting_period,
  count(*) OVER (partition by year,month) as days
FROM dim.date
where year(date) = 2024),

targets as (select
    gb.budget_version
  , gb.posting_period
  , gb.channel
  , SUM(gb.budget_amount) as Target
  FROM
    fact.gl_budget gb
  inner join
    dim.gl_account ga
    on ga.account_id_edw = gb.account_id_edw
    and ga.account_number >= 4000 and ga.account_number < 5000
group by 1,2,3)


SELECT 
budget_version as year, pm.date,
t.channel,
  
  coalesce(target*bf.percent,target/pm.days) as revenue,
  from
period_map pm 
LEFT JOIN targets t on t.posting_period = pm.posting_period 
  LEFT JOIN google_sheets.november_2024_revenue_dist bf on bf.transaction_date = pm.date and channel in ('Goodr.com','goodr.ca')
  where budget_version LIKE '2024%' and channel is not null 
order by date, channel