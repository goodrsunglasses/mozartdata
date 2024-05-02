WITH
  cash AS (
    SELECT
      sum(net_amount) AS cash,
      posting_period,
      transaction_date
    FROM
      fact.gl_transaction
    WHERE
      account_number >= 1010
      AND account_number < 1100
      AND posting_flag = 'true'
    GROUP BY
      posting_period,
      transaction_date
  ),
  revenue AS (
    SELECT
      sum(net_amount) AS revenue,
      posting_period,
      transaction_date
    FROM
      fact.gl_transaction
    WHERE
      account_number like '4%'
      AND posting_flag = 'true'
    GROUP BY
      posting_period,
      transaction_date
  )
SELECT
  c.*,
  r.revenue
FROM
  cash c
  LEFT JOIN revenue r ON 
   c.posting_period = r.posting_period
  AND c.transaction_date = r.transaction_date