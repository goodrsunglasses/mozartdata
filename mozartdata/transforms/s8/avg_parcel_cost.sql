SELECT
--  location,
--  detailed_carrier,
  ship_month,
  channel_coalesce,
  sum(total_shipping_less_duties) AS total_shipping_less_duties,
  count(*) AS parcel_count,
  round(sum(total_shipping_less_duties) / count(*), 3) AS avg_parcel_cost,
--  count(distinct(order_number_wms)) as order_count_wms,
  count(distinct(api_order_id_edw)) as order_count_goodr
FROM
  s8.stord_invoices
--where ship_month = '2024-04-01' and channel_coalesce = 'goodr.ca'        -- for qc 
  GROUP BY
  ALL
  ORDER BY
  ship_month,
  channel_coalesce
--  location,
--  detailed_carrier