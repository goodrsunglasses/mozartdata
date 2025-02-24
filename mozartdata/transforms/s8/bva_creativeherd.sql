SELECT
  t.gl_transaction_id_edw,
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
  t.department_id_ns in (16,20,22,6,21)
  and posting_period like '%2025'
  and t.account_number >= 5000
  and posting_flag

--select distinct (DEPARTMENT), department_id_ns FROM  fact.gl_transaction order by department