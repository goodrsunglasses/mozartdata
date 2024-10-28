select 
    invoice,
    billed_date,
    ship_date,
    order_number_wms as goodr_order_number,
    total_shipping_less_duties as total_paid,
    source_file
  from stord_invoices.a_combined
UNION
  select 
    invoice_number as invoice,
    billed_date,
    ship_date,
    order_number_wms as goodr_order_number,
    total_shipping_less_duties as total_paid,
    source_file
  from stord_invoices.b_combined
UNION
  select 
    invoice,
    billed_date,
    ship_date,
    order_number_wms as goodr_order_number,
    total_shipping_less_duties as total_paid,
    source_file
  from stord_invoices.c_combined
UNION
  select 
    "UNNAMED:_0" as invoice,
    billed_date,
    ship_date,
    order_number_wms as goodr_order_number,
    total_shipping_less_duties as total_paid,
    source_file
  from stord_invoices.d_combined
UNION
  select 
    invoice_number as invoice,
    invoice_date as billed_date,
    job_date as ship_date,
    null as goodr_order_number,
    total_charge as total_paid,
    source_file
  from stord_invoices.e_combined
UNION
  select 
    invoice,
    billed_date,
    ship_date,
    order_number_wms as goodr_order_number,
    total_shipping_less_duties as total_paid,
    source_file
  from stord_invoices.f_combined