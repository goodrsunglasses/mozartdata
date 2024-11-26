SELECT
  sum(total_cost),
  billed_date,
  channel_guess
FROM
  archive.stord_invoices_combined
GROUP BY
  ALL