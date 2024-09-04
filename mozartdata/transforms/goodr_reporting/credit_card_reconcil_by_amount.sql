WITH
  exclusion AS (--gotta do this to make sure to find all the unique amounts on the statements AFTER we can confirm they are previously matcheable
    SELECT
      tran.*,
      recon.transaction_number_ns as exluded_number
    FROM
      s8.credit_card_reconciliation_transactions tran
      LEFT OUTER JOIN goodr_reporting.credit_reconcil_direct_join recon ON recon.transaction_number_ns = tran.transaction_number_ns
    WHERE
      recon.transaction_number_ns IS NULL
  ),