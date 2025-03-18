SELECT
--  location,
--  detailed_carrier,
  ship_month,
  channel_coalesce,
  sum(total_shipping_less_duties) AS total_shipping_less_duties,
  count(*) AS parcel_count,
  round(sum(total_shipping_less_duties) / count(*), 3) AS avg_parcel_cost,
  count(distinct(order_id_edw_coalesce)) as order_count_goodr,
  round(sum(total_shipping_less_duties) / count(distinct(order_id_edw_coalesce)), 3) AS avg_order_cost
FROM
  s8.stord_invoices
--where ship_month = '2024-04-01' and channel_coalesce = 'goodr.ca'        -- for qc 
where channel_coalesce <> 'other'
  GROUP BY
  ALL
  ORDER BY
  ship_month,
  channel_coalesce
--  location,
--  detailed_carrier