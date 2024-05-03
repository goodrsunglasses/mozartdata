with 
  actuals as (
  select
  posting_period,
  to_date(posting_period, 'MON YYYY') posting_period_date,
  sum(case when account_number like '4%' then net_amount end) as revenue,
  sum(case when account_number like '5%' then net_amount end) as cogs,
  sum(case when account_number like '6%' or account_number like '7%' then net_amount end) as opex,
  --- net income
  sum(case when account_number like '60%' then net_amount end) as fulfillment,
  sum(case when account_number like '61%' then net_amount end) as product_dev,
  sum(case when account_number like '63%' then net_amount end) as sales_and_marketing,
  sum(case when account_number like '70%' then net_amount end) as labor,
  sum(case when account_number like '7%' and account_number not like '70%' then net_amount end) as g_and_a,
  from
  fact.gl_transaction gt
  where posting_flag = 'true'
group by 
posting_period,to_date(posting_period, 'MON YYYY') 
  )
select * from actuals