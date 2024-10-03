with combined as (
      SELECT
        ship_date,
        order_number_wms as goodr_order_number,
        shipment_tracking_number as tracking,
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
        shipment_tracking_number as tracking,
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
        shipment_tracking_number as  tracking,
        total_shipping_less_duties  as total_cost,
        CASE
          when location = 'ATLANTA' then 'ATL'
          when location = 'LAS VEGAS 2' then 'LAS 2'
          when location =  'LAS VEGAS' then 'LAS'
          else 'OTHER'
          END as location,
        billed_date,
        source_file
      FROM
        stord_invoices.three_combined
    union 
      SELECT
        to_date(job_date, 'mm/dd/yyyy hh:mi:ss AM') as ship_date, 
        reference_1 as goodr_order_number,
        tracking_number_vendor as  tracking,
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
        shipment_tracking_number as tracking,
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
        tracking_number_vendor as  tracking,
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
        tracking_number_vendor as  tracking,
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
        tracking_number as tracking,
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
        tracking_number as tracking,
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
        tracking_number as tracking,
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
        tracking_number as tracking,
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
        tracking_number as tracking,
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
        tracking_number_vendor as  tracking,
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
        tracking_number_vendor as  tracking,
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
        tracking_number_vendor as  tracking,
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
        tracking_number_vendor as  tracking,
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
        tracking_number_vendor as  tracking,
        total_charge  as total_cost,
        concat(processing_facility, '-',customer_name ) as location,
        invoice_date as billed_date, 
        source_file
      FROM
          stord_invoices.seventeen_combined
 )
, ranked  AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY tracking, total_cost 
               ORDER BY billed_date, 
                        CASE 
                            WHEN LEFT(source_file, 3) = LEFT(location, 3) THEN 1 
                            ELSE 2 
                        END
           ) AS rn
    FROM Combined
 ) 

SELECT 
  ship_date,
  goodr_order_number,
  tracking,
  total_cost,
  location,
  billed_date,
  source_file,
  CASE
    WHEN left(goodr_order_number, 3) is null then 'sellgoodr ca'
    WHEN left(goodr_order_number, 3) = 'GCA' THEN 'goodr.ca'
    WHEN left(goodr_order_number, 3) = 'GW-' THEN 'goodrwill'
    WHEN left(goodr_order_number, 3) = 'CAB' THEN 'cabana'
    WHEN left(goodr_order_number, 2) = 'SG' THEN 'sellgoodr'
    WHEN left(goodr_order_number, 1) = 'G' THEN 'goodr.com'
    WHEN left(goodr_order_number, 3) = 'POP' THEN 'sellgoodr pop'
    WHEN left(goodr_order_number, 2) = 'TO' THEN 'transfer order'
    WHEN left(goodr_order_number, 2) = 'CS' THEN 'customer service'
    WHEN left(goodr_order_number, 3) = 'SD-' THEN 'marketing'
    WHEN left(goodr_order_number, 3) = 'PR-' THEN 'marketing'
    WHEN left(goodr_order_number, 3) = 'SIG' THEN 'marketing'
    WHEN left(goodr_order_number, 3) = 'BRA' THEN 'sellgododr'
    WHEN left(goodr_order_number, 3) = 'PO-' THEN 'sellgoodr'
    ELSE 'other'
    END AS channel_guess,
FROM ranked
WHERE rn = 1
ORDER BY tracking, total_cost