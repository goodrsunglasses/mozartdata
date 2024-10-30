WITH
  calc_clean AS (
    SELECT
      licensor,
      CASE
        WHEN channel_combo = 'Sellgoodr' THEN 'Specialty'
        ELSE channel_combo
      END AS clean_channel,
      rate,
      rate_percent
    FROM
      google_sheets.licensing_rate_calculations
  )
SELECT
  calc.rate,
  calc.rate_percent,
  detail.*
FROM
  goodr_reporting.pr_licensing_transactions detail
  LEFT OUTER JOIN google_sheets.licensing_rate_calculations calc ON lower(calc.licensor) = lower(detail.licensor)
  AND lower(calc.channel_combo) = lower(detail.channel)