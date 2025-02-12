SELECT
  order_id_edw,
  ship_date as ship_date_stord,
  ship_date_ns
FROM
  fact.fulfillment
WHERE
  source_system = 'Stord'
  AND ship_date BETWEEN '2025-01-01T00:00:00' AND '2025-01-31T23:59:59'
and ship_date_ns is null