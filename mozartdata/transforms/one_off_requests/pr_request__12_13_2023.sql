SELECT
  gltran.order_id_edw,
  gltran.transaction_id_ns,
  line.transaction_number_ns as created_from_transaction,
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
  left outer join fact.order_line line on line.transaction_id_ns=gltran.createdfrom
WHERE
  gltran.transaction_id_ns like '%IF%' and created_from_date between '2023-11-23' and '2023-11-30'