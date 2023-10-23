SELECT
  acct.fullname,
  budgets.*
FROM
  netsuite.budgets budgets
left outer join netsuite."ACCOUNT" acct on acct.id = budgets."ACCOUNT"
where fullname= 'Cost of Goods Sold'