--This one is not a union because I didn't get to editing it until after I added mapping join logic to fact.credit_card_merchant.
SELECT
  concat(
    'AMEX',
    TO_VARCHAR(LAST_DAY(DATE, 'MONTH'), 'MMDDYYYY')
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
  LEFT OUTER JOIN google_sheets.amex_ns_vendor_map map ON upper(map.vendor) = upper(statement.clean_merchant)
WHERE
  source = 'AMEX'
  AND card_member = 'JANE WU'
  AND DATE >= DATE_TRUNC('MONTH', DATEADD(MONTH, -1, CURRENT_DATE))
  AND DATE < DATE_TRUNC('MONTH', CURRENT_DATE)
ORDER BY
  DATE