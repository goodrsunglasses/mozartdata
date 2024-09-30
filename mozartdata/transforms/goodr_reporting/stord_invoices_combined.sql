SELECT
    ship_date,
    order_number_wms as goodr_order_number,
    shipment_tracking_number as tracking_or_shipping_id,
    total_shipping_less_duties as total_cost,
    location,
    billed_date,
    source_file
  FROM
    stord_invoices.one_combined
UNION
  SELECT
    ship_date,
    order_number_wms as goodr_order_number,
    shipment_tracking_number as tracking_or_shipping_id,
    total_shipping_less_duties  as total_cost,
    CASE
      WHEN LEFT(source_file, 3) = 'ATL' THEN 'ATL'
      WHEN LEFT(source_file, 3) = 'LAS' THEN 'LAS'
      ELSE 'OTHER'
    END AS location,
    billed_date,
    source_file
  FROM
    stord_invoices.two_combined 
union 
  SELECT
    ship_date,
    order_number_wms as goodr_order_number,
    shipment_tracking_number as  tracking_or_shipping_id,
    total_shipping_less_duties  as total_cost,
    location,
    billed_date,
    source_file
  FROM
    stord_invoices.three_combined
union 
  SELECT
    to_date(job_date, 'mm/dd/yyyy hh:mi:ss AM') as ship_date, 
    reference_1 as goodr_order_number,
    tracking_number_vendor as  tracking_or_shipping_id,
    total_charge  as total_cost,
    concat(processing_facility, '-',customer_name ) as location,
    to_date(invoice_date, 'mm/dd/yyyy hh:mi:ss AM') as billed_date, 
    source_file
  FROM
      stord_invoices.four_combined
union
  SELECT
    ship_date,
    order_number_wms as goodr_order_number,
    shipment_tracking_number as tracking_or_shipping_id,
    total_shipping_less_duties as total_cost,
    CASE
      WHEN LEFT(source_file, 3) = 'ATL' THEN 'ATL'
      WHEN LEFT(source_file, 3) = 'LAS' THEN 'LAS'
      ELSE 'OTHER'
      END AS location,
    billed_date,
    source_file
  FROM
    stord_invoices.five_combined
union 
  SELECT
    job_date as ship_date,
    reference_1 as goodr_order_number,
    tracking_number_vendor as  tracking_or_shipping_id,
    total_charge as total_cost,
    concat(processing_facility, '-',customer_name ) as location,
    invoice_date as billed_date,
    source_file
  FROM
    stord_invoices.six_combined
union 
  SELECT
    job_date as ship_date,
    reference_1 as goodr_order_number,
    tracking_number_vendor as  tracking_or_shipping_id,
    null_column_name as total_cost,
    concat(processing_facility, '-',customer_name ) as location,
    invoice_date as billed_date,
    source_file
  FROM
    stord_invoices.seven_combined
UNION
  SELECT
    ship_date,
    order_number as goodr_order_number,
    tracking_number as tracking_or_shipping_id,
    total_cost,
    case
      when origin_facility = 'ATLANTA' then 'ATL'
      when origin_facility = 'LAS VEGAS 2' then 'LAS 2'
      when origin_facility =  'LAS VEGAS' then 'LAS'
      else 'OTHER'
      end as location,
    billed_date,
    source_file
  FROM
    stord_invoices.eight_combined
union 
  SELECT
    ship_date,
    order_number as goodr_order_number,
    tracking_number as tracking_or_shipping_id,
    total_cost,
    CASE
      WHEN LEFT(source_file, 3) = 'ATL' THEN 'ATL'
      WHEN LEFT(source_file, 3) = 'LAS' THEN 'LAS'
      ELSE 'OTHER'
    END AS location,
    billed_date,
    source_file
  FROM
    stord_invoices.nine_combined
UNION
  SELECT
    ship_date,
    order_number as goodr_order_number,
    tracking_number as tracking_or_shipping_id,
    total_cost,
    CASE
      WHEN LEFT(source_file, 3) = 'ATL' THEN 'ATL'
      WHEN LEFT(source_file, 3) = 'LAS' THEN 'LAS'
      ELSE 'OTHER'
    END AS location,
    billed_date,
    source_file
  FROM
    stord_invoices.ten_combined
UNION
  SELECT
    ship_date,
    order_number as goodr_order_number,
    tracking_number as tracking_or_shipping_id,
    total_cost,
    CASE
      when origin_facility = 'ATLANTA' then 'ATL'
      when origin_facility = 'LAS VEGAS 2' then 'LAS 2'
      when origin_facility =  'LAS VEGAS' then 'LAS'
      else 'OTHER'
      END as location,
    billed_date,
    source_file
  FROM
    stord_invoices.eleven_combined
UNION 
  SELECT
    ship_date,
    order_number as goodr_order_number,
    tracking_number as tracking_or_shipping_id,
    total_cost,
    CASE
      WHEN LEFT(source_file, 3) = 'ATL' THEN 'ATL'
      WHEN LEFT(source_file, 3) = 'LAS' THEN 'LAS'
      ELSE 'OTHER'
    END AS location,
    billed_date,
    source_file
  FROM
    stord_invoices.twelve_combined
UNION 
  SELECT
    to_date(job_date, 'mm/dd/yyyy hh:mi:ss AM') as ship_date, 
    reference_1 as goodr_order_number,
    tracking_number_vendor as  tracking_or_shipping_id,
    total_charge  as total_cost,
    concat(processing_facility, '-',customer_name ) as location,
    bill_date as billed_date, 
    source_file
  FROM
      stord_invoices.thirteen_combined
UNION 
  SELECT
    to_date(job_date, 'mm/dd/yyyy hh:mi:ss AM') as ship_date, 
    reference_1 as goodr_order_number,
    tracking_number_vendor as  tracking_or_shipping_id,
    total_charge  as total_cost,
    concat(processing_facility, '-',customer_name ) as location,
    to_date(invoice_date, 'mm/dd/yyyy hh:mi:ss AM') as billed_date, 
    source_file
  FROM
      stord_invoices.fourteen_combined
UNION 
  SELECT
    to_date(job_date, 'mm/dd/yyyy hh:mi:ss AM') as ship_date, 
    reference_1 as goodr_order_number,
    tracking_number_vendor as  tracking_or_shipping_id,
    total_charge  as total_cost,
    concat(processing_facility, '-',customer_name ) as location,
    to_date(invoice_date, 'mm/dd/yyyy hh:mi:ss AM') as billed_date, 
    source_file
  FROM
      stord_invoices.fifteen_combined
UNION 
  SELECT
    to_date(job_date, 'mm/dd/yyyy hh:mi:ss AM') as ship_date, 
    reference_1 as goodr_order_number,
    tracking_number_vendor as  tracking_or_shipping_id,
    total_charge  as total_cost,
    concat(processing_facility, '-',customer_name ) as location,
    date_from_parts(2024, 04, 11) as billed_date, 
    source_file
  FROM
      stord_invoices.sixteen_combined
UNION 
  SELECT
    ship_date, 
    reference_1 as goodr_order_number,
    tracking_number_vendor as  tracking_or_shipping_id,
    total_charge  as total_cost,
    concat(processing_facility, '-',customer_name ) as location,
    invoice_date as billed_date, 
    source_file
  FROM
      stord_invoices.seventeen_combined