SELECT
  line.transaction,
  gl_tran.transaction_number_ns,
  gl_tran.transaction_date,
  line.entity,
  line.expenseaccount,
  acc.account_display_name,
  gl_tran.account_number,
  CASE
    WHEN to_varchar(gl_tran.account_number) LIKE '2020%' THEN 'AMEX'
    ELSE 'JPM'
  END AS bank,
  gl_tran.credit_amount as net_amount,
  emp.altname,
  emp.firstname,
  emp.lastname,
  concat(firstname, ' ', lastname) AS first_last,
  line.cleared,
  CASE --This case whens is basically the business logic that determines whether or not we can join a given NS transaction DIRECTLY to the bank transactions we import
    WHEN (
      count(altname) over (
        PARTITION BY
          transaction_date,
          net_amount,
          altname
      )
    ) > 1 THEN FALSE
    ELSE TRUE
  END AS unique_amount_per_name_per_day
FROM
  netsuite.transactionline line
  LEFT OUTER JOIN fact.gl_transaction gl_tran ON (
    line.transaction = gl_tran.transaction_id_ns
    AND gl_tran.account_id_edw = line.expenseaccount
  )
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = line.transaction
  LEFT OUTER JOIN netsuite.entity emp ON emp.id = line.entity
  LEFT OUTER JOIN dim.gl_account acc ON acc.account_id_ns = line.expenseaccount
WHERE
  cleared_flag = FALSE
  AND record_type IN (
    'journalentry',
    'creditcardcharge',
    'vendorpayment',
    'check'
  )
  AND (
    to_varchar(gl_tran.account_number) LIKE '2020%'
    OR to_varchar(gl_tran.account_number) LIKE '2021%'
  )
  AND credit_amount > 0
  AND voided = 'F'
  AND net_amount != 0
  AND posting_flag = TRUE