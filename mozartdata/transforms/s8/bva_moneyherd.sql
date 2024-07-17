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
  a.account_display_name
FROM
  fact.gl_transaction t
  left join dim.gl_account a on a.account_id_edw = t.account_id_edw
WHERE
  department in ('Business Intelligence','Accounting','Finance Herd')
  and posting_period like '%2024'