WITH
  combined AS (

    ---------------- cleaned SIX 
    SELECT
      origin_facility AS location,
      LEFT(source_file, 10) AS invoice,
      Carrier AS detailed_carrier,
      account_number,
      billed_date,
      order_number AS order_number_wms,
      tracking_number AS shipment_tracking_number,
      customer_name,
      ship_date,
      destination_address AS destination_address_1,
      final_destination_city AS destination_city,
      final_destination_state AS destination_state,
      final_destination_zip AS destination_zip,
      final_destination_country AS destination_country,
      shipping_method,
      stord_service_level,
      "BILLED_WEIGHT_(OZ)" AS sum_package_weight,
      zone,
      duty AS duties_charge,
      NULL AS ancillary_charges_2,
      fuel AS fuel_charges,
      residential AS residential_charges,
      shipping_charge_correction AS shipping_charges,
      total_cost AS total_shipping_less_duties,
      source_file
    FROM
      stord_invoices.mar_upload_6
    UNION ALL
    ---------------- cleaned FIVE 
    SELECT
      origin_facility AS location,
      LEFT(source_file, 10) AS invoice,
      Carrier AS detailed_carrier,
      account_number,
      billed_date,
      order_number AS order_number_wms,
      tracking_number AS shipment_tracking_number,
      customer_name,
      ship_date,
      destination_address AS destination_address_1,
      final_destination_city AS destination_city,
      final_destination_state AS destination_state,
      final_destination_zip AS destination_zip,
      final_destination_country AS destination_country,
      shipping_method,
      stord_service_level,
      weight_in_ounces AS sum_package_weight,
      zone,
      duty AS duties_charge,
      NULL AS ancillary_charges_2,
      fuel AS fuel_charges,
      residential AS residential_charges,
      shipping_charge_correction AS shipping_charges,
      total_cost AS total_shipping_less_duties,
      source_file
    FROM
      stord_invoices.mar_upload_5
    UNION ALL
    ---------------- cleaned FOUR  -- CANNOT BE CLEANED, this is pivot tables (INV6027954 Goodr LAS Parcel 11.25 and 12.2.2024 - updated.xlsx)
    ---------------- cleaned THREE 
    SELECT
      origin_facility AS location,
      LEFT(source_file, 10) AS invoice,
      Carrier AS detailed_carrier,
      account_number,
      billed_date,
      order_number AS order_number_wms,
      tracking_number AS shipment_tracking_number,
      customer_name,
      ship_date,
      destination_address AS destination_address_1,
      final_destination_city AS destination_city,
      final_destination_state AS destination_state,
      final_destination_zip AS destination_zip,
      final_destination_country AS destination_country,
      shipping_method,
      stord_service_level,
      weight_in_ounces AS sum_package_weight,
      zone,
      duty AS duties_charge,
      NULL AS ancillary_charges_2,
      fuel AS fuel_charges,
      residential AS residential_charges,
      shipping_charge_correction AS shipping_charges,
      total_cost AS total_shipping_less_duties,
      source_file
    FROM
      stord_invoices.mar_upload_3
    UNION ALL
    ---------------- cleaned TWO  
    SELECT
      origin_facility AS location,
      LEFT(source_file, 10) AS invoice,
      Carrier AS detailed_carrier,
      account_number,
      billed_date,
      order_number AS order_number_wms,
      tracking_number AS shipment_tracking_number,
      customer_name,
      ship_date,
      destination_address AS destination_address_1,
      final_destination_city AS destination_city,
      final_destination_state AS destination_state,
      final_destination_zip AS destination_zip,
      final_destination_country AS destination_country,
      shipping_method,
      stord_service_level,
      weight_in_ounces AS sum_package_weight,
      zone,
      duty AS duties_charge,
      NULL AS ancillary_charges_2,
      fuel AS fuel_charges,
      residential AS residential_charges,
      shipping_charge_correction AS shipping_charges,
      total_cost AS total_shipping_less_duties,
      source_file
    FROM
      stord_invoices.mar_upload_2
    UNION ALL
    ---------------- cleaned ONE
    SELECT
      origin_facility AS location,
      LEFT(source_file, 10) AS invoice,
      Carrier AS detailed_carrier,
      account_number,
      billed_date,
      order_number AS order_number_wms,
      tracking_number AS shipment_tracking_number,
      customer_name,
      ship_date,
      destination_address AS destination_address_1,
      final_destination_city AS destination_city,
      final_destination_state AS destination_state,
      final_destination_zip AS destination_zip,
      final_destination_country AS destination_country,
      shipping_method,
      stord_service_level,
      weight_in_ounces AS sum_package_weight,
      zone,
      duty AS duties_charge,
      NULL AS ancillary_charges_2,
      fuel AS fuel_charges,
      residential AS residential_charges,
      shipping_charge_correction AS shipping_charges,
      total_cost AS total_shipping_less_duties,
      source_file
    FROM
      stord_invoices.mar_upload_1
    UNION ALL
    SELECT
      origin_facility AS location,
      'las_20241007' AS invoice,
      carrier AS detailed_carrier,
      NULL AS account_number,
      billed_date,
      order_number AS order_number_wms,
      tracking_number AS shipment_tracking_number,
      customer_name,
      ship_date,
      destination_address AS destination_address_1,
      final_destination_city AS destination_city,
      final_destination_state AS destination_state,
      final_destination_zip AS destination_zip,
      final_destination_country AS destination_country,
      NULL AS shipping_method,
      stord_service_level,
      weight_in_ounces AS sum_package_weight,
      zone,
      duty duties_charge,
      other AS ancillary_charges_2,
      fuel fuel_charges,
      residential residential_charges,
      NULL AS shipping_charges,
      total_cost AS total_shipping_less_duties,
      'staging_ las_20241007' AS source_file
    FROM
      stord_invoices.las_20241007
      ---  stord_invoices.inv6027590 (all duplicates)
    UNION ALL
    --- parcel_details
    SELECT
      location::text,
      invoice::text,
      detailed_carrier::text,
      account_number::text,
      COALESCE(
        TRY_TO_DATE(BILLED_DATE, 'YYYY-MM-DD'),
        TRY_TO_DATE(BILLED_DATE, 'MM/DD/YYYY HH:MI:SS AM'),
        TRY_TO_DATE(BILLED_DATE, 'MM/DD/YYYY')
      ) AS billed_date_converted,
      order_number_wms::text,
      shipment_tracking_number::text,
      customer_name::text,
      COALESCE(
        TRY_TO_DATE(ship_DATE, 'YYYY-MM-DD'),
        TRY_TO_DATE(ship_DATE, 'MM/DD/YYYY HH:MI:SS AM'),
        TRY_TO_DATE(ship_DATE, 'MM/DD/YYYY')
      ) AS ship_DATE_converted,
      destination_address_1::text,
      destination_city::text,
      destination_state::text,
      destination_zip::text,
      destination_country::text,
      shipping_method::text,
      stord_service_level::text,
      sum_package_weight::text,
      zone::text,
      duties_charge,
      ancillary_charges_2,
      fuel_charges,
      residential_charges,
      shipping_charges,
      total_shipping_less_duties,
      'parcel_details' AS source_file
    FROM
      stord_invoices.parcel_details
  union all 
   ------------- cleaned april 
    SELECT
      origin_facility AS location,
      inv AS invoice,
      Carrier AS detailed_carrier,
      account_number,
      billed_date,
      order_number AS order_number_wms,
      tracking_number AS shipment_tracking_number,
      customer_name,
      ship_date,
      destination_address AS destination_address_1,
      final_destination_city AS destination_city,
      final_destination_state AS destination_state,
      final_destination_zip AS destination_zip,
      final_destination_country AS destination_country,
      shipping_method,
      stord_service_level,
      "BILLED_WEIGHT_(OZ)" AS sum_package_weight,
      zone,
      duty AS duties_charge,
      NULL AS ancillary_charges_2,
      fuel AS fuel_charges,
      residential AS residential_charges,
      shipping_charge_correction AS shipping_charges,
      total_cost AS total_shipping_less_duties,
      source_file
   FROM
      stord_invoices.apr_upload_1

  
  )
SELECT
  location,
  invoice,
  detailed_carrier,
  account_number,
  billed_date,
  order_number_wms,
  shipment_tracking_number,
  customer_name,
  ship_date,
  destination_address_1,
  destination_city,
  destination_state,
  destination_zip,
  destination_country,
  shipping_method,
  stord_service_level,
  sum_package_weight,
  zone,
  duties_charge,
  ancillary_charges_2,
  fuel_charges,
  residential_charges,
  shipping_charges,
  total_shipping_less_duties,
  source_file
FROM
  combined

  /*   QC FOR DUPLICATES 
  WHERE (shipment_tracking_number, total_shipping_less_duties)
  IN (
  SELECT shipment_tracking_number, total_shipping_less_duties
  FROM combined
  GROUP BY shipment_tracking_number, total_shipping_less_duties
  HAVING COUNT(DISTINCT source_file) > 1
  )
  order by shipment_tracking_number, invoice
  */