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
      map.netsuite_account_num,
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
        AND map.date = per_day_ns.transaction_date
      ) --Idea here is to basically join on when the banks are the same, the amounts are the sam, the names are the same and the days are the same, because boolean wise all these transactions from both ends are GUARANTEED to be unique per person per day.
    WHERE
      map.unique_amount_per_name_per_day = TRUE
  )
SELECT
  per_day_join.*,
  cardholder.difference AS aggregate_cardholder_diff
FROM
  per_day_join
  LEFT OUTER JOIN goodr_reporting.credit_reconcil_by_cardholder cardholder ON cardholder.expenseaccount = per_day_join.netsuite_account_num
WHERE
  transaction_number_ns IS NOT NULL
  AND aggregate_cardholder_diff != 0 --Ok so the idea here is to cascade the logic, to not include the ones that could have been previously cleared via the first step found in the credit_reconcil_by_cardholder query