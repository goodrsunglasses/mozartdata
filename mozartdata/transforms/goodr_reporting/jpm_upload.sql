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
and map.vendor is not null
union all 
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
  LEFT OUTER JOIN google_sheets.jpm_ns_vendor_map map ON map.statement_name = statement.appears_on_your_statement_as
WHERE
  card_member = 'JANE'
  AND source = 'JPM'
and  statement.clean_merchant is null