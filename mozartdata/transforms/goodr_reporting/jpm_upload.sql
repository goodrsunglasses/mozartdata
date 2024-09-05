WITH
  cleaned_list AS (
    SELECT
      transaction_id,
      post_date,
      merchant_name,
      map.*
    FROM
      google_sheets.jpmastercard_upload import
      LEFT OUTER JOIN google_sheets.jpmc_mapping map ON map.statement_name = import.merchant_name
    WHERE
      account_given_name = 'JANE'
  )
SELECT
  transaction_id,
  clean_merchant,
  post_date,
  amount,
  Vendor,
  GL,
  Internal,
  Account_Name,
  Department,
  ID,
  Line_Memo
FROM
  google_sheets.jpmc_mapping map
  LEFT OUTER JOIN cleaned_list ON map.vendor = cleaned_list.clean_merchant
WHERE
  amount IS NOT NULL