SELECT
  concat(
    'AMEX',
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
  appears_on_your_statement_as,
  clean_merchant AS memo,
  DATE,
  amount,
  Vendor,
  GL,
  Internal,
  Description line_memo,
  Department,
  Department_id,
FROM
  fact.credit_card_merchant_map statement
  LEFT OUTER JOIN google_sheets.amex_ns_vendor_map map ON upper(map.statement_name) = upper(statement.clean_merchant)
WHERE
  source = 'AMEX'
  AND card_member = 'JANE WU'