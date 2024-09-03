WITH
  jpm_agg AS (
    SELECT
      transaction_id,
      'JPM' AS bank,
      account_given_name,
      amount,
      count(amount) over (
        PARTITION BY
          account_given_name,
          amount
      ) counter
    FROM
      google_sheets.jpmastercard_upload
    ORDER BY
      amount
  ),
  amex_agg AS (
    SELECT
      reference,
      'AMEX' AS bank,
      card_member,
      amount,
      count(amount) over (
        PARTITION BY
          card_member,
          amount
      ) counter
    FROM
      google_sheets.amex_full_compare
    ORDER BY
      amount
  ),
  unique_amounts AS (
    SELECT
      *
    FROM
      jpm_agg
    WHERE
      counter = 1
    UNION ALL
    SELECT
      *
    FROM
      amex_agg
    WHERE
      counter = 1
  )