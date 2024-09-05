SELECT
  concat(
    'JPM',
    TO_VARCHAR(LAST_DAY(TO_DATE(post_date, 'MM/DD/YYYY'), 'MONTH'), 'MMDDYYYY')
  ) || LPAD(
    ROW_NUMBER() OVER (
      ORDER BY
        post_date
    ),
    3,
    '0'
  ) AS external_id,
  Vendor AS memo,
  post_date,
  amount,
  Vendor,
  GL,
  Internal,
  Account_Name,
  map.Department,
  ID as Department_id,
  Line_Memo
FROM
  google_sheets.jpmastercard_upload import
  LEFT OUTER JOIN google_sheets.jpmc_mapping map ON map.statement_name = import.merchant_name
WHERE
  account_given_name = 'JANE'