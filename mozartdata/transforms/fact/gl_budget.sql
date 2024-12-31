/*
 Created a unique primary key. In some cases the channel or department can be null, so we have to coalesce those values

 */
SELECT
  md5(concat(bl."ACCOUNT",'_',bl.category,'_',coalesce(bl.cseg7,0),'_',coalesce(bl.department,0),'_',bl.period)) as gl_budget_id_edw,
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
GROUP BY ALL

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