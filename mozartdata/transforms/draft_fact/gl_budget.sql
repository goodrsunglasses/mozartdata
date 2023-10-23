SELECT
  acct.fullname,
  machine.amount,
  machine.period,
  category.name cat,
  budgets.*
FROM
  netsuite.budgets budgets
left outer join netsuite."ACCOUNT" acct on acct.id = budgets."ACCOUNT"
  left outer join netsuite.budgetcategory category on category.id = budgets.category
  left outer join netsuite.budgetsmachine machine on machine.budget = budgets.id
where acct.fullname = 'Cost of Goods Sold'
and cat = '2023 - V2'
and amount >0