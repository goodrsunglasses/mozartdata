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
  calc_clean.rate,
  calc_clean.rate_percent,
  detail.*
FROM
  goodr_reporting.pr_licensing_transactions detail
  LEFT OUTER JOIN calc_clean ON lower(calc_clean.licensor) = lower(detail.licensor)
  AND lower(calc_clean.clean_channel) = lower(detail.channel)
WHERE
  detail.licensor IS NOT NULL
  AND rate IS NULL