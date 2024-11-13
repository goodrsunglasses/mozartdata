--NOTE OSU CHANGED POST 2024 TO BE 15%, WE CHANGED THAT IN THE SOURCE MAPPING DATA BUT ANY ROYALTY PAYMENT CALC FOR PRE JULY 2024 FOR OHIO STATE WILL BE SLIGHTLY OFF
WITH
  calc_clean AS (
    SELECT
      licensor,
      CASE
        WHEN channel_combo = 'Sellgoodr' THEN 'Specialty'
        WHEN channel_combo = 'D2C' THEN 'Goodr.com'
        WHEN channel_combo = 'B2B' THEN 'Specialty'
        ELSE channel_combo
      END AS clean_channel,
      rate,
      rate_percent
    FROM
      google_sheets.licensing_rate_calculations
  )
SELECT
  detail.licensor,
  detail.product_id_edw,
  detail.posting_period,
  detail.channel,
  calc_clean.rate as calc_method,
  calc_clean.rate_percent,
  detail.net_sales_ns,
  detail.net_sales_shop,
  detail.net_sales_no_discount_ns,
  detail.net_sales_no_discount_shop,
  CASE
    WHEN rate = 'Net' THEN net_sales_ns * rate_percent
   WHEN rate = 'Net w/o Discounts' then net_sales_no_discount_ns * rate_percent
  END AS royalty_payment_ns,
  CASE
    WHEN rate = 'Net' THEN net_sales_shop * rate_percent
    WHEN rate = 'Net w/o Discounts' then net_sales_no_discount_shop * rate_percent
  END AS royalty_payment_shop
FROM
  goodr_reporting.pr_licensing_transactions detail
  LEFT OUTER JOIN calc_clean ON lower(calc_clean.licensor) = lower(detail.licensor)
  AND lower(calc_clean.clean_channel) = lower(detail.channel)