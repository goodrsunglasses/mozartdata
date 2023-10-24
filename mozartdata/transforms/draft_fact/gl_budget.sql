SELECT
  sum(amount)
FROM
  netsuite.budgetlegacy budgets
left outer join netsuite."ACCOUNT" acct on acct.id = budgets."ACCOUNT"
  left outer join netsuite.budgetcategory category on category.id = budgets.category
where acct.fullname = 'Cost of Goods Sold'
  and cseg7 = 7
and category.name = '2023 - V2'