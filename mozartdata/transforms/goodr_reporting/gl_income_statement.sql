/*
This report produces an Income statement which can be reconciled against Net Suite

Aliases:
gt = draft_fact.gl_transaction
ga = dim.gl_account
*/

select
  ga.account_number
, ga.account_full_name
, concat(ga.account_number,' - ',ga.account_full_name) account_with_name
, gt.channel
, sum(gt.amount_transaction) amount_transaction
, sum(gt.amount_net) amount_net
, sum(gt.amount_credit) amount_credit
, sum(gt.amount_debit) amount_debit
, sum(gt.amount_transaction_positive) amount_transaction_positive
from
  draft_fact.gl_transaction gt
inner join
  dim.gl_account ga
  on ga.account_id_ns = gt.account_id_ns
where
  gt.posting_period = --in ('Feb 2023','Mar 2023','Apr 2023','May 2023','Jun 2023','Jul 2023','Aug 2023','Sep 2023')
  and posting_flag = true
and ga.account_number >= 4000 and ga.account_number < 9000
group by
  ga.account_number
, ga.account_full_name
, concat(ga.account_number,' - ',ga.account_full_name)
, gt.channel