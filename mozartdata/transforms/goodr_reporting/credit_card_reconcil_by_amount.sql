WITH
  ns_exclusion AS ( --gotta do this to make sure to find all the unique amounts on the statements AFTER we can confirm they are previously matcheable
    SELECT
      tran.*,
      recon.transaction_number_ns AS exluded_number
    FROM
      s8.credit_card_reconciliation_transactions tran
      LEFT OUTER JOIN goodr_reporting.credit_reconcil_direct_join recon ON recon.transaction_number_ns = tran.transaction_number_ns
    WHERE
      recon.transaction_number_ns IS NULL
  ),
  bank_exclusion AS ( --Here we do it for the banks to be extra safe, basically getting two unique lists between NS and the Bank statements of all the ones that have yet to be matched so we can isolate unique counts
    SELECT
      bank.*,
      recon.transaction_number_ns AS exluded_number
    FROM
      fact.credit_card_merchant_map bank
      LEFT OUTER JOIN goodr_reporting.credit_reconcil_direct_join recon ON recon.reference = bank.reference
    WHERE
      recon.reference IS NULL
  ),
  unique_ns AS ( --This is where we determine what the unique amounts are PER BANK out of NS 
    SELECT
      transaction,
      transaction_number_ns,
      bank,
      first_last,
      net_amount,
      CASE
        WHEN (
          count(net_amount) over (
            PARTITION BY
              net_amount,
              bank
          )
        ) > 1 THEN FALSE
        ELSE TRUE
      END AS ns_counter
    FROM
      ns_exclusion
  where first_last not like '%JANE%'
    ORDER BY
      net_amount asc
  ),
  unique_bank AS ( --This is where we determine what the unique amounts are PER BANK out of the bank statements 
    SELECT
      reference,
      card_member,
      amount,
      source,
      CASE
        WHEN (
          count(amount) over (
            PARTITION BY
              amount,
              source
          )
        ) > 1 THEN FALSE
        ELSE TRUE
      END AS counter
    FROM
      bank_exclusion
  where card_member not like '%JANE%'
  )
SELECT
  unique_ns.transaction,
  unique_ns.transaction_number_ns,
  unique_ns.bank,
  unique_ns.first_last,
  unique_ns.net_amount,
  unique_bank.reference,
  unique_bank.card_member,
  unique_bank.amount,
  unique_bank.source
FROM
  unique_ns
  LEFT OUTER JOIN unique_bank ON (unique_bank.amount = unique_ns.net_amount and unique_bank.source = unique_ns.bank)
WHERE
  counter
  AND ns_counter 
ORDER BY
  amount