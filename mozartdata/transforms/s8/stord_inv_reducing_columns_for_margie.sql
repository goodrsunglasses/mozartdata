SELECT
  shipment_tracking_number,
  api_tracking_number,
  cut_tracking_number,
--  order_number_wms,
--  api_order_id_edw,
  order_id_edw_coalesce,
  location,
  invoice,
  detailed_carrier,
  stord_service_level,
  billed_date,
  ship_date,
  api_ship_date,
  state_ful,
  subtotal,
  shipping_income,
  total_shipping_less_duties,
  api_qty,
  channel_coalesce,
  code,
  free_ship_threshold,
  standard_priority,
  shipping_region,
  source_file
FROM
  s8.stord_invoices
where ship_date between '2024-10-01' and '2025-03-31'
--WHERE api_order_id_edw LIKE 'G%'  
--  AND api_order_id_edw = 'G-CA12238'
--ORDER BY  api_order_id_edw