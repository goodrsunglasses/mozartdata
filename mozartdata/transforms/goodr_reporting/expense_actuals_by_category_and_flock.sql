select
  ga.budget_category
, gt.department
, gt.posting_period
, gt.account_number
, sum(gt.net_amount) as net_amount
, ga.account_display_name as account_name
FROM
  fact.gl_transaction gt
inner join
  dim.gl_account ga
  on gt.account_id_edw = ga.account_id_edw
WHERE
  gt.posting_flag
and gt.posting_period like '%2024'
and ga.budget_category is not null
and ga.account_number between '6000' and '6999'
group by all