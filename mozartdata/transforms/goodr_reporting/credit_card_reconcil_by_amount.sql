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
  unique_ns AS (
    SELECT
      transaction,
      net_amount,
      case when (count(net_amount) over (partition by net_amount))>1 then false else true end as AS counter
    FROM
      ns_exclusion
    ORDER BY
      net_amount asc
  )
select * from unique_ns where counter >1