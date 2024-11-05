WITH
  dates AS (--min date max date logic for AMEX because we're doing a huge import, and want to make sure to only display values for this that are not used for the jane import
    SELECT
      source,
      max(date_min) AS date_min,
      min(date_max) AS date_max
    FROM
      fact.credit_card_merchant_map
    GROUP BY
      source
  ),
  aggregates AS (
    SELECT
      expenseaccount,
      account_display_name,
      account_number,
      bank,
      round(
        sum(
          CASE
            WHEN transaction_date BETWEEN dates.date_min AND dates.date_max  THEN net_amount
            WHEN bank = 'JPM' THEN net_amount
            ELSE 0
          END
        ),
        2
      ) AS total_credit_amount_ns,
      sum(amount) AS bank_statement_amount
    FROM
      s8.credit_card_reconciliation_transactions tran
      LEFT OUTER JOIN dates ON dates.source = tran.bank
      LEFT OUTER JOIN fact.credit_card_merchant_map bank_tran ON bank_tran.netsuite_account_num = tran.expenseaccount
    WHERE
      account_number NOT IN (2020, 2021) --pointedly ignoring these two accounts, because going forward all the expenses should be reclassed into a sub account, and may be double homed in the old big one, only jane transactions should stay there.
    GROUP BY
      ALL
    ORDER BY
      account_display_name
  )
SELECT
  aggregates.*,
  round(abs(total_credit_amount_ns - bank_statement_amount),2) AS difference
FROM
  aggregates