/*
This report produces an Income statement which can be reconciled against Net Suite

Aliases:
gt = fact.gl_transaction
ga = draft_dim.gl_account
*/

select
  ga.account_number
, ga.account_full_name
, concat(ga.account_number,' - ',ga.account_full_name) account_with_name
, gt.channel
, gt.posting_period
, sum(gt.amount_transaction) amount_transaction
, sum(gt.amount_net) amount_net
, sum(gt.amount_credit) amount_credit
, sum(gt.amount_debit) amount_debit
, sum(gt.amount_transaction_positive) amount_transaction_positive
from
  fact.gl_transaction gt
inner join
  draft_dim.gl_account ga
  on ga.account_id_ns = gt.account_id_ns
where
  right(gt.posting_period,4) = '2023'
  and posting_flag = true
and ga.account_number >= 4000 and ga.account_number < 4200 and channel <> ''
group by
  ga.account_number
, ga.account_full_name
, concat(ga.account_number,' - ',ga.account_full_name)
, gt.channel
, gt.posting_period