WITH
  ns_info AS (
    SELECT
      line.transaction,
      gl_tran.transaction_number_ns,
      gl_tran.transaction_date,
      line.entity,
      line.expenseaccount,
      gl_tran.account_number,
      CASE
        WHEN gl_tran.account_number = '2020' THEN 'AMEX'
        ELSE 'JPM'
      END AS bank,
      gl_tran.net_amount,
      emp.altname,
      emp.firstname,
      emp.lastname,
      concat(firstname, ' ', lastname) AS first_last,
      line.cleared,
      CASE
        WHEN (
          count(altname) over (
            PARTITION BY
              transaction_date,
              net_amount,
              altname
          )
        ) > 1 THEN FALSE
        ELSE TRUE
      END AS splay_counter
    FROM
      netsuite.transactionline line
      LEFT OUTER JOIN fact.gl_transaction gl_tran ON (
        line.transaction = gl_tran.transaction_id_ns
        AND gl_tran.account_id_edw = line.expenseaccount
      )
      LEFT OUTER JOIN netsuite.transaction tran ON tran.id = line.transaction
      LEFT OUTER JOIN netsuite.entity emp ON emp.id = line.entity
    WHERE
      cleared_flag = FALSE
      AND record_type IN (
        'journalentry',
        'creditcardcharge',
        'vendorpayment',
        'check'
      )
      AND account_number IN (2020, 2021)
      AND voided = 'F'
      AND net_amount != 0
      AND posting_flag = TRUE
  )
SELECT
  *
FROM
  ns_info
WHERE
  transaction_date = '2024-07-27'
  AND altname = 'USA Postal Service'