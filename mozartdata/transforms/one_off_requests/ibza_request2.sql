with ranks as 
  (
SELECT
  order_id_edw_coalesce,
  total_shipping_less_duties,
  destination_zip,
  location,
  sum_package_weight,
  api_qty,
  RANK() OVER (
    PARTITION BY order_id_edw_coalesce
    ORDER BY sum_package_weight DESC
  ) AS rank
FROM
  s8.stord_invoices
ORDER BY
  order_id_edw_coalesce, sum_package_weight DESC 
  )
SELECT
  order_id_edw_coalesce,
  total_shipping_less_duties,
  destination_zip,
  location,
  sum_package_weight,
  api_qty
FROM
  ranks where rank = 1