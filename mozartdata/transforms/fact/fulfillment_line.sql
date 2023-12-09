SELECT
  fulfillment_id_edw,
  carriercode,
  servicecode,
  shipdate,
  ordernumber,
  shipmentcost,
  voided,
  shipto:CITY::STRING AS city,
  shipto:COUNTRY::STRING AS country,
  shipto:STATE::STRING AS state
FROM
  dim.fulfillment fulfill
  LEFT OUTER JOIN shipstation_portable.shipstation_shipments_8589936627 shipstation ON TO_CHAR(shipstation.shipmentid) = fulfill.source_system_id
WHERE
  source_system = 'Shipstation'
  --Stord
UNION ALL
SELECT
  fulfillment_id_edw,
  stord.carrier_name,
  stord.carrier_service_method,
  stord.shipped_at,
  stord.order_number,
  NULL AS shipmentcost,
  is_canceled,
  orders.destination_address:NORMALIZED_LOCALITY::STRING,
  orders.destination_address:NORMALIZED_COUNTRY_CODE::STRING,
  orders.destination_address:NORMALIZED_COUNTRY_SUBDIVISION_CODE::STRING
FROM
  dim.fulfillment fulfill
  LEFT OUTER JOIN stord.stord_shipment_confirmations_8589936822 stord ON stord.shipment_confirmation_id = fulfill.source_system_id
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 orders ON orders.order_id = stord.order_id
WHERE
  source_system = 'Stord'