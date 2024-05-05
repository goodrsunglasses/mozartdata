

with all_balances as
  (
SELECT
  h.posting_period
, h.posting_date
, h.account_number
, gt.account_id_ns
, gt.account_id_edw
, h.amount as balance
FROM google_sheets.balance_dec_21 h
left join fact.gl_transaction gt on gt.account_number = h.account_number
UNION
SELECT
 gt.posting_period
, to_date(gt.posting_period,'MON YYYY') posting_date
, gt.account_number
, gt.account_id_ns
, gt.account_id_edw
, sum(gt.net_amount) as balance
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
select
  ab.posting_period
, ab.account_id_edw
, ab.account_number
, ab.balance as current_period_amount
, sum(ab.balance) over (partition by ab.account_number order by ab.posting_date) as ending_balance
FROM
  all_balances ab
order by
  ab.account_number
, ab.posting_date