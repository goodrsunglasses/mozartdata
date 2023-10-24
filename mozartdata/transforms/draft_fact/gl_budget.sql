SELECT
  acct.fullname,
  category.name AS YEAR,
  cseg7.name as channel,
  SUM(amount) AS amount
FROM
  netsuite.budgetlegacy budgets
  LEFT OUTER JOIN netsuite."ACCOUNT" acct ON acct.id = budgets."ACCOUNT"
  LEFT OUTER JOIN netsuite.budgetcategory category ON category.id = budgets.category
  LEFT OUTER JOIN netsuite.customrecord_cseg7 cseg7 ON cseg7.id = budgets.cseg7

GROUP BY
  acct.fullname,
  cseg7.name,
  YEAR