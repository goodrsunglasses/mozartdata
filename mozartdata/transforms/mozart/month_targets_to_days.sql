With revenue as 
(SELECT 
  * ,
  SUM(revenue) OVER (PARTITION BY month,channel) as month_rev,
  count(*) over (PARTITION BY month,channel) as days_in_month
  
  from 
(SELECT
transaction_date,
  month(transaction_date) as month,
  channel,
  sum(net_amount) as revenue
FROM fact.gl_transaction where posting_flag = true and account_number like '4%' and year(transaction_date) = 2023
  and channel in ('Amazon','Cabana','Goodr.com','Global','Key Account','Prescription','Specialty')
group by 1,2,3 ) a ) ,
  date_map as 
  (
  SELECT name as channel, date
  from dim.channel 
  RIGHT JOIN (SELECT * FROM dim.date where YEAR(date) = 2023 ) d on 1=1
  where name in ('Amazon','Cabana','Goodr.com','Global','Key Account','Prescription','Specialty') 
  )

  SELECT * , month_rev/days_in_month as divide_evenly, revenue/iff(month_rev=0,1,month_rev) as past_performance 
  FROM 
  (SELECT *,  SUM(revenue) OVER (PARTITION BY month,dm_channel) as month_rev, count(*) over (PARTITION BY month,dm_channel) as days_in_month 

  FROM 
(SELECT dm.channel as dm_channel, dm.date, MONTH(dm.date) as month,zeroifnull(r.revenue) as revenue  FROM date_map dm
  LEFT JOIN revenue r on dm.channel = r.channel and dm.date = r.transaction_date) a) b