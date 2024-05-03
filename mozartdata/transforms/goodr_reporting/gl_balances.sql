SELECT
  (sum(gt.net_amount) + sum(h.amount)) as balance,
  h.account_number,
  gt.account_id_ns,
  gt.account_id_edw
FROM google_sheets.balance_dec_21 h
left join fact.gl_transaction gt on gt.account_number = h.account_number
  where gt.posting_flag = 'true'
group by 2,3,4






SELECT
  transaction_line_id,
  order_id_edw,
  order_id_ns,
  transaction_id_ns,
  transaction_number_ns,
  account_id_edw,
  account_id_ns,
  account_number,
  channel,
  transaction_timestamp,
  transaction_date,
  transaction_timestamp_pst,
  transaction_date_pst,
  date_posted_pst,
  posting_flag,
  posting_period,
  transaction_amount,
  credit_amount,
  debit_amount,
  normal_balance_amount,
  net_amount,
  parent_transaction_id_ns,
  department_id_ns,
  item_id_ns,
  department
FROM fact.gl_transaction