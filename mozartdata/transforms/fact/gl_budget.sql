SELECT
  bl."ACCOUNT" as account_id_edw,
  ga.account_number,
  category.name AS budget_version,
  cseg7.name as channel,
  bl.department as department_id_ns,
  d.name as department,
  bl.period as period_id_ns,
  ap.posting_period as posting_period,
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
    dim.accounting_period ap
    on bl.period = ap.accounting_period_id
  left join
    netsuite.department d
    on d.id = bl.department
where
  bl.date_deleted is null
GROUP BY
  bl."ACCOUNT",
  ga.account_display_name,
  ga.account_number,
  category.name,
 cseg7.name,
  bl.period,
  ap.posting_period,
  bl.department,
  d.name

--- temporary budget for 2024-v4 may
UNION
select 
  268 as account_id_edw,
  4000 as account_number,
  '2024-V4' as budget_version,
  channel,
  null as department_id_ns,
  null as netsuite_department,
  78 as period_id_ns,
  'May 2024' as posting_period,
  target as budget_amount,
FROM google_sheets.may_2024_v_4_revenue_targets