with oct_las as (
SELECT 
  origin_facility as location,
  null as invoice,
  carrier as   detailed_carrier,
  null as   account_number,
  CAST(billed_date AS DATE) as billed_date,
  order_number as   order_number_wms,
  tracking_number as   shipment_tracking_number,
  customer_name,
  CAST(ship_date AS DATE) as ship_date,
  destination_address as   destination_address_1,
  final_destination_city as   destination_city,
  final_destination_state as   destination_state,
  final_destination_zip as   destination_zip,
  final_destination_country as   destination_country,
  null as shipping_method,
  stord_service_level,
  weight_in_ounces as  sum_package_weight,
  zone,
  duty duties_charge,
  other as ancillary_charges_2,
  fuel fuel_charges,
  residential residential_charges,
  null as shipping_charges,
  total_cost as total_shipping_less_duties
  FROM stord_invoices.las_20241007
  )
  select * from oct_las
  union all 
  select * from stord_invoices.parcel_details