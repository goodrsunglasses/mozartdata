WITH
  dates AS (
    SELECT
      source,
      max(date_min) AS date_min,
      min(date_max) AS date_max
    FROM
      fact.credit_card_merchant_map
    GROUP BY
      source
  )
SELECT
  expenseaccount,
  account_display_name,
  first_last,
  account_number,
  bank,
  sum(
    CASE
      WHEN transaction_date BETWEEN date_min AND date_max  THEN net_amount
      ELSE 0
    END
  ) AS total_credit_amt_ns
FROM
  s8.credit_card_reconciliation_transactions tran
  LEFT OUTER JOIN dates ON dates.source = tran.bank
WHERE
  firstname IS NOT NULL
GROUP BY
  ALL