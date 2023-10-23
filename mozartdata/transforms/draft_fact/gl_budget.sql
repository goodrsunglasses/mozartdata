SELECT
  acct.fullname,
  machine.amount,
  machine.period,
  location.fullname,
  dept.fullname,
  period.periodname,
  category.name,
  budgets.id,
  budgets."ACCOUNT",
  budgets.category,
  budgets.department,
  budgets.location,
  budgets.total
FROM
  netsuite.budgets budgets
left outer join netsuite."ACCOUNT" acct on acct.id = budgets."ACCOUNT"
  left outer join netsuite.accountingperiod period on period.id = budgets.year
  left outer join netsuite.budgetcategory category on category.id = budgets.category
  left outer join netsuite.location location on budgets.location = location.id
  left outer join netsuite.department dept on dept.id = budgets.department
  left outer join netsuite.budgetsmachine machine on machine.budget = budgets.id
where acct.fullname = 'Cost of Goods Sold'
and periodname = 'FY 2023'