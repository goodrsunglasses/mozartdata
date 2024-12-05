SELECT
--  location,
--  detailed_carrier,
  ship_month,
  channel_coalesce,
  sum(total_shipping_less_duties) AS total_shipping_less_duties,
  count(*) AS parcel_count,
  round(sum(total_shipping_less_duties) / count(*), 3) AS avg_parcel_cost
FROM
  s8.stord_invoices
GROUP BY
  ALL
ORDER BY
  ship_month,
  channel_coalesce
--  location,
--  detailed_carrier