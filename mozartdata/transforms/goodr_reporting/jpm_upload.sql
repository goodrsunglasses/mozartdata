SELECT
  transaction_id,
  merchant_name statement_merchant,
  post_date,
  amount,
  Vendor,
  GL,
  Internal,
  Account_Name,
  map.Department,
  ID,
  Line_Memo
FROM
  google_sheets.jpmastercard_upload import
  LEFT OUTER JOIN google_sheets.jpmc_mapping map ON map.statement_name = import.merchant_name
WHERE
  account_given_name = 'JANE'