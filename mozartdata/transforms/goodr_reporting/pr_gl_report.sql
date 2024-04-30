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
  AND abs(net_amount) > 0
  AND account_number LIKE '4%'
UNION ALL
SELECT
  *
FROM
  fact.gl_transaction
WHERE
  channel IS NULL
  AND posting_flag = TRUE
  AND abs(net_amount) > 0
  AND account_number LIKE '4%'
  and posting_period like '%2024'
ORDER BY
  transaction_date desc