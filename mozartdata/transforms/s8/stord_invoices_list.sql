SELECT DISTINCT
  (
    COALESCE(
      try_to_date(ship_date),
      try_to_date(ship_date_stord_api)
    )
  ) AS dates,
  invoice
FROM
  s8.stord_invoices
WHERE
  dates IS NOT NULL
ORDER BY
  dates desc