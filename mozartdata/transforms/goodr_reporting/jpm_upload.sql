--This one is a union due to the fact that at one point I didn't have logic in fact.credit_card_merchants to catch and attempt to join the mapping data to the statement data after it had been adjusted
--However now, once the mapping is updated, it will be handled in fact.credit_card_merchant_map instead of needing to be handled in the uploads
WITH
  unioned AS (
    SELECT
      appears_on_your_statement_as,
      clean_merchant AS memo,
      DATE,
      amount,
      GL,
      Internal,
      Account_Name,
      map.Department,
      ID AS Department_id,
      Line_Memo
    FROM
      fact.credit_card_merchant_map statement
      LEFT OUTER JOIN google_sheets.jpm_ns_vendor_map map ON map.vendor = statement.clean_merchant
    WHERE
      card_member = 'JANE'
      AND source = 'JPM'
      AND map.vendor IS NOT NULL
    UNION ALL
    SELECT
      appears_on_your_statement_as,
      vendor AS memo,
      DATE,
      amount,
      GL,
      Internal,
      Account_Name,
      map.Department,
      ID AS Department_id,
      Line_Memo
    FROM
      fact.credit_card_merchant_map statement
      LEFT OUTER JOIN google_sheets.jpm_ns_vendor_map map ON map.statement_name = statement.appears_on_your_statement_as
    WHERE
      card_member = 'JANE'
      AND source = 'JPM'
      AND statement.clean_merchant IS NULL
  )
SELECT
  concat(
    'JPM',
    TO_VARCHAR(
      LAST_DAY(TO_DATE(DATE, 'MM/DD/YYYY'), 'MONTH'),
      'MMDDYYYY'
    )
  ) || LPAD(
    ROW_NUMBER() OVER (
      ORDER BY
        DATE
    ),
    3,
    '0'
  ) AS external_id,
  unioned.*
FROM
  unioned