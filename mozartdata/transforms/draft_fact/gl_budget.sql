SELECT
  bl."ACCOUNT" as account_id_ns,
  ga.account_display_name,
  ga.account_number,
  category.name AS budget_version,
  cseg7.name as channel,
  bl.period,
  ap.periodname,
  SUM(amount) AS amount
FROM
  netsuite.budgetlegacy bl
  LEFT JOIN 
    draft_dim.gl_account ga 
  ON ga.account_id_ns = bl."ACCOUNT"
  LEFT JOIN 
    netsuite.budgetcategory category 
    ON category.id = bl.category
  LEFT JOIN 
    netsuite.customrecord_cseg7 cseg7 
    ON cseg7.id = bl.cseg7
  left join
    netsuite.accountingperiod ap
    on bl.period = ap.id
WHERE
  budget_version = '2023 - V3'
GROUP BY
  bl."ACCOUNT",
  ga.account_display_name,
  ga.account_number,
  category.name,
  cseg7.name,
  bl.period,
   ap.periodname
order by 
  period,
  account_number,
  channel

/*
SELECT * FROM netsuite.accountingperiod
SELECT * FROM netsuite.budgetlegacy
*/