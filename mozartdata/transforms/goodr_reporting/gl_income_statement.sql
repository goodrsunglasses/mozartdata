/*
This report produces an Income statement which can be reconciled against Net Suite

Aliases:
gt = fact.gl_transaction
ga = dim.gl_account
*/

select
  ga.account_number
, ga.account_full_name
, gt.channel
, gt.amount_net
, gt.amount_credit
, gt.amount_debit
, gt.amount_transaction_positive
from
  fact.gl_transaction gt
inner join
  dim.gl_account ga
  on ga.account_id_ns = gt.account_id_ns
where
  gt.posting_period = 'Jan 2023'
and ga.account_number = 4000 and ga.account_number < 7000