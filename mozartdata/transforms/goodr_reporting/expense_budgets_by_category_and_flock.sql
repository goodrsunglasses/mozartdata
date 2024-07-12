select
  ga.budget_category
, gb.budget_version
, gb.department
, gb.posting_period
, gb.account_number
, gb.budget_amount
, ga.account_display_name as account_name
FROM
  fact.gl_budget gb
inner join
  dim.gl_account ga
  on gb.account_id_edw = ga.account_id_edw
WHERE
 gb.posting_period like '%2024' 
and gb.budget_category is not null
and gb.account_number between '6000' and '6999'