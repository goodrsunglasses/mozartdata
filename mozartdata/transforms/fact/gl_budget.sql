SELECT
  bl."ACCOUNT" as account_id_edw,
  ga.account_number,
  version.name AS budget_version,
  cseg7.name as channel,
  bl.department as department_id_ns,
  d.name as department,
  ga.budget_category,
  bl.period as period_id_ns,
  ap.posting_period as posting_period,
  SUM(bl.amount) AS budget_amount
FROM
  netsuite.budgetlegacy bl
  LEFT JOIN 
    dim.gl_account ga 
  ON ga.account_id_edw = bl."ACCOUNT"
  LEFT JOIN 
    netsuite.budgetcategory version
    ON version.id = bl.category
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
  version.name,
 cseg7.name,
  bl.period,
  ap.posting_period,
  bl.department,
  d.name

--- temporary budget for 2024-v4 may
  /*
UNION
select 
  rt.account_id_ns as account_id_edw,
  rt.account_number,
  '2024 - V4' as budget_version,
  rt.channel,
  null as department_id_ns,
  null as netsuite_department,
  ap.accounting_period_id as period_id_ns,
  rt.posting_period as posting_period,
  rt.amount as budget_amount,
FROM google_sheets.may_2024_v_4_revenue_targets rt
left join dim.accounting_period ap
  on rt.posting_period = ap.posting_period
*/