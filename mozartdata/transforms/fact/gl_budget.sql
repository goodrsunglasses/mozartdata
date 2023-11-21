SELECT
  bl."ACCOUNT" as account_id_edw,
  ga.account_number,
  category.name AS budget_version,
  cseg7.name as channel,
  bl.period as period_id_ns,
  ap.periodname as posting_period,
  SUM(bl.amount) AS budget_amount
FROM
  netsuite.budgetlegacy bl
  LEFT JOIN 
    dim.gl_account ga 
  ON ga.account_id_edw = bl."ACCOUNT"
  LEFT JOIN 
    netsuite.budgetcategory category 
    ON category.id = bl.category
  LEFT JOIN 
    netsuite.customrecord_cseg7 cseg7 
    ON cseg7.id = bl.cseg7
  left join
    netsuite.accountingperiod ap
    on bl.period = ap.id
GROUP BY
  bl."ACCOUNT",
  ga.account_display_name,
  ga.account_number,
  category.name,
 cseg7.name,
  bl.period,
  ap.periodname