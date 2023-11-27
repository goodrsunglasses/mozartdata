/*
This report produces an Income statement which can be reconciled against Net Suite

Aliases:
gt = fact.gl_transaction
ga = dim.gl_account
*/

select
  ga.account_number
, ga.account_full_name
, concat(ga.account_number,' - ',ga.account_full_name) account_with_name
, gt.posting_period
, gt.channel
, sum(gt.transaction_amount) transaction_amount
, sum(gt.net_amount) net_amount
, sum(gt.credit_amount) credit_amount
, sum(gt.debit_amount) debit_amount
from
  fact.gl_transaction gt
inner join
  dim.gl_account ga
  on ga.account_id_ns = gt.account_id_ns
where
  gt.posting_period  in ('Jan 2023','Feb 2023','Mar 2023','Apr 2023','May 2023','Jun 2023','Jul 2023','Aug 2023','Sep 2023')
  and posting_flag = true
and ga.account_number >= 4000 and ga.account_number < 9000
group by
  ga.account_number
, ga.account_full_name
, concat(ga.account_number,' - ',ga.account_full_name)
, gt.channel
, gt.posting_period