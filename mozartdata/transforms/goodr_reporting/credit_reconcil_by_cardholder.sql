WITH
  card_agg AS ( --This one is to attempt to aggregate the totals by cardholder to eliminate any easy ones
    SELECT
      entity,
      altname,
      firstname,
      lastname,
      upper(first_last) AS first_last, --Upper it for later joining to the bank statements
      account_number,
      bank,
      sum(net_amount) total_amount
    FROM
      s8.credit_card_reconciliation_transactions
    WHERE
      firstname IS NOT NULL
    GROUP BY
      altname,
      first_last,
      entity,
      firstname,
      lastname,
      account_number,
      bank
  ),
  bank_agg AS (
    SELECT
      Upper(clean_card_member) AS clean_card_member, --upper case to join to to the Netsuite transactions,
      source AS bank,
      sum(amount) amount_sum
    FROM
      fact.credit_card_merchant_map
    GROUP BY
      clean_card_member,
      bank
  ),
  cardholder_compare AS ( --This is basically step one as of rn, you go ahead and compare the aggregations of a given cardholder's bank data to their NS data, meaning that when they match u can reconcile them.
    SELECT
      clean_card_member AS statement_name_upper,
      first_last AS ns_name_upper,
      bank_agg.bank,
      total_amount AS aggregate_amount_ns,
      amount_sum AS aggregate_amount_statement,
      
    FROM
      bank_agg
      LEFT OUTER JOIN card_agg ON (
        bank_agg.clean_card_member = card_agg.first_last
        AND bank_agg.bank = card_agg.bank
      )
  )
SELECT
  *
FROM
  cardholder_compare
where ns_name_upper is not null