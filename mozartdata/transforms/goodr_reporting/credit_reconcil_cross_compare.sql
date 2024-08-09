WITH
  ns_info AS (
    SELECT
      line.transaction,
      gl_tran.transaction_number_ns,
      gl_tran.transaction_date,
      line.entity,
      line.expenseaccount,
      gl_tran.account_number,
      gl_tran.net_amount,
      emp.altname,
      emp.firstname,
      emp.lastname,
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
  card_agg AS ( --This one is to attempt to aggregate the totals by cardholder to eliminate any easy ones
    SELECT
      altname,
      firstname,
      lastname,
      account_number,
      sum(net_amount)
    FROM
      ns_info
    GROUP BY
      altname,
      firstname,
      lastname,
      account_number
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
      transaction_number_ns,
      net_amount,
      transaction_date,
      altname,
      amex.reference
    FROM
      first_list
      LEFT OUTER JOIN google_sheets.amex_import amex ON (
        amex.date = first_list.transaction_date
        AND first_list.net_amount = amex.amount
        AND upper(amex.card_member) = upper(first_list.first_last)
      )
    WHERE
      reference IS NOT NULL
  )
SELECT
  *
FROM
  card_agg