/*
--- netsuite : 1669287.6600000001  (4000, Jan 2025)
SELECT
  sum(net_amount),
  channel,
  date_trunc(MONTH, transaction_date)
  --  posting_period
FROM
  fact.gl_transaction
WHERE
  posting_flag
  AND account_number LIKE '4000'
  AND posting_period LIKE '%2025'
GROUP BY
  ALL
  ---------
SELECT
  sum(net_amount),
  channel,
  posting_period
FROM
  fact.gl_transaction
WHERE
  posting_flag
  AND account_number LIKE '4000'
  AND posting_period LIKE '%2025'
GROUP BY
  ALL
ORDER BY
  3,
  2
  --------
SELECT DISTINCT
  (transaction_date)
FROM
  fact.gl_transaction
WHERE
  posting_period = 'Jan 2025'
  AND account_number LIKE '4%'
  AND posting_flag
ORDER BY
  1
  ----------
SELECT
  *
FROM
  fact.gl_transaction
WHERE
  posting_period = 'Jan 2025'
  AND posting_flag
  AND transaction_date < '2025-01-01'
  AND account_number LIKE '4%'
  */
  ---------
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
 AND account_number LIKE '4%'
  AND transaction_month <> posting_period_month
  and (transaction_month like '2025%' or posting_period_month like '2025%')

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