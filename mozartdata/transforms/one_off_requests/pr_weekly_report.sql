SELECT
  *
FROM
  fact.gl_transaction
WHERE
  channel IN (
    'Goodrwill.com',
    'Customer Service CAN',
    'Goodrstock Giveaways',
    'Customer Service',
    'Marketing'
  )
  AND posting_flag = TRUE
  AND net_amount > 0
  and account_number like '4%'
ORDER BY
  transaction_date desc