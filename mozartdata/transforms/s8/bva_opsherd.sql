SELECT
  t.transaction_line_id,
  t.transaction_number_ns,
  t.account_id_ns,
  t.account_number,
  t.transaction_date,
  t.posting_flag,
  t.posting_period,
  t.net_amount,
  t.department,
  t.budget_category,
  t.channel,
  t.memo,
  a.account_display_name,
  t.line_memo,
  t.line_class,
  t.line_entity,
  t.line_entity_type,
  t.entity,
  t.entity_type
FROM
  fact.gl_transaction t
  left join dim.gl_account a on a.account_id_edw = t.account_id_edw
WHERE
  t.department_id_ns in (9,53138,23,11,18332,14,17)
  and transaction_date >= '2024-08-01'
  and posting_period like '%2024'
  and t.account_number >= 5000 
  and t.account_number <> 6016
  and posting_flag
  
--select distinct (DEPARTMENT), department_id_ns FROM  fact.gl_transaction order by department