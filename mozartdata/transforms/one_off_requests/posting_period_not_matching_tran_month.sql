SELECT
  t.transaction_id_ns,
  t.order_id_ns,
  t.net_amount,
  t.account_number,
  t.channel,
  t.posting_period,
  t.transaction_date,
  date_trunc(MONTH, transaction_date) AS transaction_month,
--  min(d.date) as posting_period_month
  date_trunc(MONTH, d.period_start) as posting_period_month
FROM
  fact.gl_transaction t
  left join (select  posting_period, min(date) period_start from dim.date group by 1) d on t.posting_period = d.posting_period
WHERE
  posting_flag
 AND account_number LIKE '4%'             --- revenue only 
  AND transaction_month <> posting_period_month
  and (transaction_month like '2025%' or posting_period_month like '2025%')         ---- only looking at things that happened in or impact 2025 

-------- TOTALS 
  /*
select
  date_trunc(month,gt.transaction_date) transaction_date_month
, gt.posting_period
, gt.account_number
, ap.period_start_date
, sum(gt.net_amount)
-- , gt.order_id_edw
-- , gt.transaction_id_ns
from
  fact.gl_transaction gt
inner join
  dim.accounting_period ap
on gt.posting_period = ap.posting_period
where
  gt.account_number like '4%'
and posting_flag
and gt.posting_period = 'Nov 2024'
and date_trunc(month,gt.transaction_date) != ap.period_start_date
group by all
order by period_start_date asc
*/