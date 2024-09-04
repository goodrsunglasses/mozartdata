WITH
  per_day_ns AS ( --First grab all the NS credit card transactions that are unique per person per day to later join them to the bank statements
    SELECT
      *
    FROM
      s8.credit_card_reconciliation_transactions
    WHERE
      unique_amount_per_name_per_day = TRUE
  ),
  per_day_join AS (
    SELECT
      map.reference,
      map.source,
      map.amount,
      map.clean_card_member,
      per_day_ns.transaction_number_ns,
      per_day_ns.transaction_date,
      per_day_ns.account_number,
      per_day_ns.first_last
    FROM
      fact.credit_card_merchant_map map
      LEFT OUTER JOIN per_day_ns ON (
        per_day_ns.bank = map.source
        AND per_day_ns.net_amount = map.amount
        AND upper(per_day_ns.first_last) = upper(map.clean_card_member)
      )
    WHERE
      map.unique_amount_per_name_per_day = TRUE
  )
SELECT
  *
FROM
  per_day_join