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
      array_agg(DISTINCT merchant_id) AS id_list
    FROM
      google_sheets.jpmastercard_upload
    WHERE
      transaction_id IS NOT NULL
      AND merchant_name NOT LIKE '%/%'
      AND account_given_name = 'JANE'
    GROUP BY
      clean_merchant
    ORDER BY
      clean_merchant
  )
SELECT
  Transaction_ID,
  Merchant_Name,
  Merchant_ID,
  Post_Date,
  Number,
  Department,
  Amount,
  Memo,
  Class,
  Account_Number
FROM
  google_sheets.jpmastercard_upload upload