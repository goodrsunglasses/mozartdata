SELECT
  sum(total_cost),
  billed_date,
  channel_guess
FROM
  s8.stord_invoices_combined
GROUP BY
  ALL