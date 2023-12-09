SELECT
  fulfillment_id_edw,
  items.ordernumber order_id_edw,
  items.shipmentid,
  flattened_items.value:PRODUCTID::INTEGER item_id,
  flattened_items.value:QUANTITY::INTEGER quantity
FROM
  dim.fulfillment fulfill
  LEFT OUTER JOIN shipstation_portable.shipstation_shipment_items_8589936627 items ON TO_CHAR(items.shipmentid) = fulfill.source_system_id,
  LATERAL FLATTEN(input => items.shipmentitems) AS flattened_items
WHERE
  source_system = 'Shipstation'
and order_id_edw='G1928318'
  --Stord
  -- UNION ALL
  -- SELECT
  --   fulfillment_id_edw,
  --   stord.carrier_name,
  --   stord.carrier_service_method,
  --   stord.shipped_at,
  --   stord.order_number,
  --   NULL AS shipmentcost,
  --   is_canceled,
  --   orders.destination_address:NORMALIZED_COUNTRY_CODE::STRING as country,
  --   orders.destination_address:NORMALIZED_COUNTRY_SUBDIVISION_CODE::STRING as state,
  --   orders.destination_address:NORMALIZED_LOCALITY::STRING as city
  -- FROM
  --   dim.fulfillment fulfill
  --   LEFT OUTER JOIN stord.stord_shipment_confirmations_8589936822 stord ON stord.shipment_confirmation_id = fulfill.source_system_id
  --   LEFT OUTER JOIN stord.stord_sales_orders_8589936822 orders ON orders.order_id = stord.order_id
  -- WHERE
  --   source_system = 'Stord'