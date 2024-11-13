WITH
  dates AS ( --min date max date logic for AMEX because we're doing a huge import, and want to make sure to only display values for this that are not used for the jane import
    SELECT
      source,
      max(date_min) AS date_min,
      min(date_max) AS date_max
    FROM
      fact.credit_card_merchant_map
    GROUP BY
      source
  ),
  ns_aggregates AS (
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
      ) AS total_credit_amount_ns
    FROM
      s8.credit_card_reconciliation_transactions tran
      LEFT OUTER JOIN dates ON dates.source = tran.bank
    WHERE
      account_number NOT IN (2020, 2021) --pointedly ignoring these two accounts, because going forward all the expenses should be reclassed into a sub account, and may be double homed in the old big one, only jane transactions should stay there.
    GROUP BY
      ALL
    ORDER BY
      account_display_name
  ),
  bank_agg AS (
    SELECT
      netsuite_account_num,
      round(
        sum(
          CASE
            WHEN DATE BETWEEN dates.date_min AND dates.date_max
            AND tran.source = 'AMEX' THEN amount
            WHEN tran.source = 'JPM' THEN amount
            ELSE 0
          END
  
        ),
        2
      ) AS total_amount
    FROM
      fact.credit_card_merchant_map tran
  LEFT OUTER JOIN dates ON dates.source = tran.source
    GROUP BY
      ALL
  )
SELECT
  ns_aggregates.*,
  bank_agg.total_amount AS total_amount_statement,
  total_credit_amount_ns - total_amount_statement AS difference
FROM
  ns_aggregates
  LEFT OUTER JOIN bank_agg ON bank_agg.netsuite_account_num = ns_aggregates.expenseaccount