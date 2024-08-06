WITH
  cleaned_list AS (
    SELECT DISTINCT
      CASE
        WHEN merchant_name LIKE 'FACEBK%' THEN 'FACEBOOK'
        WHEN merchant_name LIKE 'GOOGL%' THEN 'GOOGLE'
        WHEN merchant_name LIKE 'SERATO%' THEN 'SERATO DJ PRO'
        WHEN merchant_name LIKE 'SNAP%' THEN 'SNAP INC'
        WHEN merchant_name LIKE 'TIKTOK%' THEN 'TIKTOK'
        WHEN merchant_name LIKE '%DIN TAI FUNG%' THEN 'DIN TAI FUNG'
        WHEN merchant_name LIKE 'USPS STAMPS%' THEN 'USA Postal Service'
        ELSE merchant_name
      END AS clean_merchant,
      post_date,
      amount
    FROM
      google_sheets.jpmastercard_upload
    WHERE
      account_given_name = 'JANE'
    ORDER BY
      clean_merchant
  )
SELECT
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