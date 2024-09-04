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
      line.cleared
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
  ),
  splay_detect AS ( --This exists because we want to join to AMEX/JPM based off of card holder,date and amount but sometimes that can be duplicated on the exact same day
    SELECT DISTINCT
      ns_info.*,
      count(altname) over (
        PARTITION BY
          transaction_date,
          net_amount,
          altname
      ) AS splay_counter
    FROM
      ns_info
  ),
  first_list AS ( --these are the ones that can actually be directly joined (we hope)
    SELECT
      *
    FROM
      splay_detect
    WHERE
      splay_counter = 1
  ),
  amex_direct_join AS ( --this one is basically joining based on when there is only one transaction of a given amount for a given person on a given day, its like 1/3rd as accurate rn
    SELECT
      transaction,
      'AMEX' AS bank,
      transaction_number_ns,
      net_amount,
      transaction_date,
      altname,
      amex.reference
    FROM
      first_list
      LEFT OUTER JOIN google_sheets.amex_full_compare amex ON (
        amex.date = first_list.transaction_date
        AND first_list.net_amount = amex.amount
        AND upper(amex.card_member) = upper(first_list.first_last)
      )
    WHERE
      reference IS NOT NULL
  ),
  jpm_direct_join AS (
    SELECT
      transaction,
      'JPM' AS bank,
      transaction_number_ns,
      net_amount,
      transaction_date,
      altname,
      jpm.reference
    FROM
      first_list
      LEFT OUTER JOIN fact.credit_card_merchant_map jpm ON (
        jpm.date = first_list.transaction_date
        AND first_list.net_amount = jpm.amount
        AND upper(jpm.clean_card_member) = upper(first_list.first_last)
      )
    WHERE
      reference IS NOT NULL
      AND source = 'JPM'
  )
SELECT
  *
FROM
  amex_direct_join
UNION ALL
SELECT
  *
FROM
  jpm_direct_join