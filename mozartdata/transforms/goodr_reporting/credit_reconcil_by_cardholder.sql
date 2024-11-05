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
  account_number,
  bank,
  sum(
    CASE
      WHEN transaction_date BETWEEN dates.date_min AND dates.date_max  THEN net_amount
      WHEN bank = 'JPM' THEN net_amount
      ELSE 0
    END
  ) AS total_credit_amt_ns,
  sum(amount) AS bank_statement_amount
FROM
  s8.credit_card_reconciliation_transactions tran
  LEFT OUTER JOIN dates ON dates.source = tran.bank
  LEFT OUTER JOIN fact.credit_card_merchant_map bank_tran ON bank_tran.netsuite_account_num = tran.expenseaccount
WHERE
  account_number NOT IN (2020, 2021)
GROUP BY
  ALL
order by account_display_name