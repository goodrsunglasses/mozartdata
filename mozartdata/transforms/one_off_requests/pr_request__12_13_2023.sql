SELECT
  gltran.order_id_edw,
  gltran.channel,
  gltran.transaction_id_ns,
  line.transaction_number_ns AS created_from_transaction,
  line.transaction_date created_from_date,
  date.posting_period line_posting_period,
  account_number_display_name_hierarchy,
  gltran.posting_period,
  gltran.transaction_amount,
  gltran.credit_amount,
  gltran.debit_amount,
  gltran.normal_balance_amount,
  gltran.net_amount
FROM
  fact.gl_transaction gltran
  LEFT OUTER JOIN dim.gl_account ACCOUNT ON ACCOUNT.account_id_edw = gltran.account_id_edw
  LEFT OUTER JOIN fact.order_line line ON line.transaction_id_ns = gltran.transaction_id_ns
  LEFT OUTER JOIN dim.date date on line.transaction_date = date.date
WHERE
  gltran.transaction_id_ns LIKE '%IF%'
  AND gltran.posting_period <> line_posting_period
  AND account_number_display_name_hierarchy IS NOT NULL
ORDER BY
  transaction_id_ns