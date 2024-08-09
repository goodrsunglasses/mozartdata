WITH
  netsuite_select AS (
    SELECT
      gl_tran.transaction_id_ns,
      gl_tran.transaction_number_ns,
      gl_tran.net_amount,
      gl_tran.transaction_date,
      record_type,
      gl_tran.memo,
      emp.altname,
      emp.firstname,
      emp.lastname,
      tran.voided,
      gl_tran.account_number,
      gl_tran.posting_flag,
      concat(firstname, ' ', lastname) AS first_last,
      line.cleared,
      SPLIT(gl_tran.memo, '|') AS parts
    FROM
      netsuite.transactionline line
      LEFT OUTER JOIN netsuite.transaction tran ON line.transaction = tran.id
      LEFT OUTER JOIN fact.gl_transaction gl_tran ON (
        tran.id = gl_tran.transaction_id_ns
        AND gl_tran.account_id_edw = line.expenseaccount
      )
      LEFT OUTER JOIN netsuite.entity emp ON emp.id = line.entity
    WHERE
      cleared != 'T'
      AND record_type IN (
        'journalentry',
        'creditcardcharge',
        'vendorpayment',
        'check'
      )
      AND account_number in (2020,2021)
      AND voided = 'F'
      AND net_amount != 0
    ORDER BY
      transaction_date asc
  ),
  aggregation_by_cardholder as (--This one is to attempt to aggregate the totals by cardholder to eliminate any easy ones
  
  )
  expensify_split AS (
    SELECT
      netsuite_select.*,
      TRIM(parts[0]) AS email,
      replace(TRIM(REPLACE(parts[3], 'Expense:', '')), '"', '') AS expense --had to do this because it puts double quotes, idk why but dont have time to fix it rn
    FROM
      netsuite_select
  ),
  splay_detect AS ( --This exists because we want to join to AMEX/JPM based off of card holder,date and amount but sometimes that can be duplicated on the exact same day
    SELECT DISTINCT
      expensify_split.*,
      count(altname) over (
        PARTITION BY
          transaction_date,
          net_amount,
          altname
      ) AS splay_counter
    FROM
      expensify_split
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
      transaction_id_ns,
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
  -- SELECT
  --   *
  -- FROM
  --   splay_detect
  -- WHERE
  --   splay_counter > 1
  -- ORDER BY
  --   transaction_date,
  --   net_amount