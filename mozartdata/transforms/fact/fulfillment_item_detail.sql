SELECT
  fulfillment_id_edw,
  items.ordernumber AS order_id_edw,
  carriercode,
  servicecode,
  shipdate,
  shipmentcost,
  voided,
  shipto:CITY::STRING AS city,
  shipto:COUNTRY::STRING AS country,
  shipto:STATE::STRING AS state,
  items.shipmentid AS shipment_id,
  flattened_items.value:PRODUCTID::INTEGER AS item_id,
  flattened_items.value:QUANTITY::INTEGER AS quantity
FROM
  dim.fulfillment fulfill
  LEFT OUTER JOIN shipstation_portable.shipstation_shipment_items_8589936627 items ON TO_CHAR(items.shipmentid) = fulfill.source_system_id,
  LATERAL FLATTEN(input => items.shipmentitems) AS flattened_items
WHERE
  source_system = 'Shipstation'
  --Stord
UNION ALL
SELECT
  fulfillment_id_edw,
  orders.order_number AS order_id_edw,
  stord.carrier_name,
  stord.carrier_service_method,
  stord.shipped_at,
  NULL AS shipmentcost,
  is_canceled,
  orders.destination_address:NORMALIZED_LOCALITY::STRING,
  orders.destination_address:NORMALIZED_COUNTRY_CODE::STRING,
  orders.destination_address:NORMALIZED_COUNTRY_SUBDIVISION_CODE::STRING,
  shipment_confirmation_id AS shipment_id,
  flattened_items.value:ITEM_ID::STRING AS item_id,
  flattened_items.value:QUANTITY::INTEGER AS quantity
FROM
  dim.fulfillment fulfill
  LEFT OUTER JOIN stord.stord_shipment_confirmations_8589936822 stord ON stord.shipment_confirmation_id = fulfill.source_system_id
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 orders ON orders.order_id = stord.order_id,
  LATERAL FLATTEN(input => stord.SHIPMENT_CONFIRMATION_LINE_ITEMS) AS flattened_items
WHERE
  source_system = 'Stord'