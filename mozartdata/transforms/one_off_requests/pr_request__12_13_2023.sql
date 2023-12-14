SELECT
  gltran.order_id_edw,
  gltran.channel,
  gltran.transaction_id_ns,
  line.transaction_number_ns AS created_from_transaction,
  line.transaction_date created_from_date,
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
  LEFT OUTER JOIN fact.order_line line ON line.transaction_id_ns = gltran.createdfrom
WHERE
  gltran.transaction_id_ns LIKE '%IF%'
  AND created_from_date BETWEEN '2023-11-23' AND '2023-11-30'
  AND posting_period = 'Dec 2023'
  AND account_number_display_name_hierarchy IS NOT NULL
ORDER BY
  transaction_id_ns