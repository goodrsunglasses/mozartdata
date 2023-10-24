SELECT
  acct.fullname,
  category.name cat,
  budgets.*
FROM
  netsuite.budgetimport budgets
left outer join netsuite."ACCOUNT" acct on acct.id = budgets."ACCOUNT"
  left outer join netsuite.budgetcategory category on category.id = budgets.category
where acct.fullname = 'Cost of Goods Sold'
and cat = '2023 - V2'