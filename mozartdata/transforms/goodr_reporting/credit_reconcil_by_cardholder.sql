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
        WHEN account_given_name = 'ALLIE' THEN 'Allison Lefton' --There aren't very many JPM holders, so I converted their names into the full ones to join to NS later 
        WHEN account_given_name = 'ROBERTO' THEN 'Rob Federic'
        WHEN account_given_name = 'LAUREN' THEN 'Lauren Larvejo'
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
        WHEN card_member = 'MICHEAL EDDY' THEN 'Michael Eddy'
        ELSE card_member
      END AS card_member,
      'AMEX' AS bank,
      sum(amount)
    FROM
      google_sheets.amex_full_compare
    GROUP BY
      card_member,
      bank
  ),
  cardholder_compare AS ( --This is basically step one as of rn, you go ahead and compare the aggregations of a given cardholder's bank data to their NS data, meaning that when they match u can reconcile them.
    SELECT
      card_agg.first_last,
      UPPER(card_agg.first_last) upper_case,
      card_agg.account_number,
      card_agg.bank,
      round(card_agg.total_amount, 2) rounded_total,
      agg_amnt,
      abs(rounded_total) - abs(agg_amnt) AS difference
    FROM
      card_agg
      LEFT OUTER JOIN bank_agg ON (
        upper(bank_agg.account_given_name) = UPPER(card_agg.first_last)
        AND card_agg.bank = bank_agg.bank
      )
    WHERE
      firstname IS NOT NULL
  )
select * from cardholder_compare