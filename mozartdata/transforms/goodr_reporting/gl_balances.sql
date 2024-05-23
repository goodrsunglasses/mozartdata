with all_balances as
  (
SELECT
  h.amount as balance,
  h.posting_period,
  h.posting_date,
  h.account_number,
  gt.account_id_ns,
  gt.account_id_edw
FROM google_sheets.balance_dec_21 h
left join fact.gl_transaction gt on gt.account_number = h.account_number
UNION
SELECT
  sum(gt.net_amount) as balance
, gt.posting_period
, to_date(gt.posting_period,'MON YYYY') posting_date
, gt.account_number
, gt.account_id_ns
, gt.account_id_edw
FROM
  fact.gl_transaction gt
WHERE
  gt.posting_flag = true
  and gt.account_number between 1000 and 3999
GROUP BY
  gt.posting_period
, to_date(gt.posting_period,'MON YYYY')
, gt.account_number
, gt.account_id_ns
, gt.account_id_edw
)
, running_balances as (
select
  ab.posting_period
, ab.posting_date
, ab.account_number
, ab.balance as period_activity
, sum(ab.balance) over (partition by ab.account_number order by ab.posting_date) as ending_balance
FROM
all_balances ab
order by
  ab.account_number
, ab.posting_date
)
SELECT
  rb.posting_period
, rb.account_number
, round(rb.ending_balance,2) ending_balance
FROM
running_balances rb
where
rb.account_number between 1010 and 1025
and rb.posting_period = 'Mar 2024'
order by account_number
-- SELECT
--   transaction_line_id,
--   order_id_edw,
--   order_id_ns,
--   transaction_id_ns,
--   transaction_number_ns,
--   account_id_edw,
--   account_id_ns,
--   account_number,
--   channel,
--   transaction_timestamp,
--   transaction_date,
--   transaction_timestamp_pst,
--   transaction_date_pst,
--   date_posted_pst,
--   posting_flag,
--   posting_period,
--   transaction_amount,
--   credit_amount,
--   debit_amount,
--   normal_balance_amount,
--   net_amount,
--   parent_transaction_id_ns,
--   department_id_ns,
--   item_id_ns,
--   department
-- FROM fact.gl_transaction