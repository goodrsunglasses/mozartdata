WITH
  cte_cash AS (
    SELECT
      sum(net_amount),
      account_number,
      channel,
      posting_period,
      transaction_date
    FROM
      fact.gl_transaction
    WHERE
      account_number >= 1010
      AND account_number < 1100
      AND posting_flag = 'true'
    GROUP BY
      account_number,
      channel,
      posting_period,
      transaction_date
  )
SELECT
  *
FROM
  cte_cash