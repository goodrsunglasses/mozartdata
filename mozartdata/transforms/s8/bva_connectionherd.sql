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
  a.account_display_name,
  t.line_memo,
  t.line_class,
FROM
  fact.gl_transaction t
  left join dim.gl_account a on a.account_id_edw = t.account_id_edw
WHERE
  t.department_id_ns in (24,4,53239,18333,8)
  and posting_period like '%2024'
  and t.account_number >= 5000
  and posting_flag

--select distinct (DEPARTMENT), department_id_ns FROM  fact.gl_transaction