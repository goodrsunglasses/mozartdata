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
  card_agg AS ( --This one is to attempt to aggregate the totals by cardholder to eliminate any easy ones
    SELECT
      entity,
      altname,
      firstname,
      lastname,
      first_last,
      account_number,
      CASE
        WHEN account_number = 2020 THEN 'AMEX'
        ELSE 'JPM'
      END AS bank,
      sum(net_amount) total_amount
    FROM
      ns_info
    GROUP BY
      altname,
      first_last,
      entity,
      firstname,
      lastname,
      account_number
  ),
  bank_agg AS (
    SELECT
      CASE
        WHEN account_given_name = 'ALLIE' THEN 'Allison'
        WHEN account_given_name = 'ROBERTO' THEN 'Rob'
        ELSE account_given_name
      END AS account_given_name,
      'JPM' AS bank,
      sum(amount) AS agg_amnt
    FROM
      google_sheets.jpmastercard_upload
    GROUP BY
      account_given_name,
      bank
    UNION ALL
    SELECT
      CASE
        WHEN card_member = 'DAN WEINSOFT' THEN 'Daniel Weinsoft'
        ELSE card_member
      END AS card_member,
      'AMEX' AS bank,
      sum(amount)
    FROM
      google_sheets.amex_import
    GROUP BY
      card_member,
      bank
  ),
  cardholder_compare AS (
    SELECT
      first_last,
      account_number,
      bank,
      total_amount,
      agg_amnt
    FROM
      card_agg
  left outer join bank_agg on (upper(bank_agg.account_given_name) = UPPER(card_agg.first_last) and card_agg.bank=bank_agg.bank)
    WHERE
      firstname IS NOT NULL
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
* from cardholder_compare