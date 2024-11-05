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
  *
FROM
  s8.credit_card_reconciliation_transactions