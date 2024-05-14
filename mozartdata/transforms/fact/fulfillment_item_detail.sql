SELECT fulfillment_id_edw,
       items.ordernumber                       AS order_id_edw,
       'Shipstation'                           AS source,
       carriercode                             AS carrier,
       servicecode                             AS carrier_service,
       shipdate,
       shipmentcost                            AS shipment_cost,
       voided,
       shipto:COUNTRY::STRING                  AS country,
       shipto:STATE::STRING                    AS state,
       shipto:CITY::STRING                     AS city,
       TO_CHAR(items.shipmentid)               AS shipment_id,
       flattened_items.value:PRODUCTID::STRING AS item_id,
       product_id_edw,
       flattened_items.value:QUANTITY::INTEGER AS quantity
FROM dim.fulfillment fulfill
         LEFT OUTER JOIN shipstation_portable.shipstation_shipment_items_8589936627 items
                         ON TO_CHAR(items.shipmentid) = fulfill.source_system_id
         CROSS JOIN LATERAL FLATTEN(INPUT => items.shipmentitems) AS flattened_items
         LEFT OUTER JOIN dim.product product ON product.item_id_shipstation = flattened_items.value:PRODUCTID::INTEGER
WHERE source_system = 'Shipstation'
--Stord
UNION ALL
SELECT fulfillment_id_edw,
       orders.order_number                                                    AS order_id_edw,
       'Stord'                                                                AS source,
       stord.carrier_name,
       stord.carrier_service_method,
       stord.shipped_at,
       NULL                                                                   AS shipmentcost,
       is_canceled,
       orders.destination_address:NORMALIZED_COUNTRY_CODE::STRING             AS state,
       orders.destination_address:NORMALIZED_COUNTRY_SUBDIVISION_CODE::STRING AS country,
       orders.destination_address:NORMALIZED_LOCALITY::STRING                 AS city,
       shipment_confirmation_id                                               AS shipment_id,
       flattened_items.value:ITEM_ID::STRING                                  AS item_id,
       product_id_edw,
       flattened_items.value:QUANTITY::INTEGER                                AS quantity
FROM dim.fulfillment fulfill
         LEFT OUTER JOIN stord.stord_shipment_confirmations_8589936822 stord
                         ON stord.shipment_confirmation_id = fulfill.source_system_id
         LEFT OUTER JOIN stord.stord_sales_orders_8589936822 orders ON orders.order_id = stord.order_id
         CROSS JOIN LATERAL FLATTEN(INPUT => stord.SHIPMENT_CONFIRMATION_LINE_ITEMS) AS flattened_items
         LEFT OUTER JOIN dim.product product ON product.item_id_stord = flattened_items.value:ITEM_ID::STRING
WHERE source_system = 'Stord'
UNION ALL
SELECT DISTINCT --adding just in case because NS joins can be funky and I don't want any duplicate lines becase one custom field has two values or something
                fulfill.FULFILLMENT_ID_EDW,
                staged.ORDER_ID_NS            AS                                         order_id_edw,
                'Netsuite'                    AS                                         source,
                custbody_shipstation_carrier_code,
                custbody_service_code,
                TO_TIMESTAMP_NTZ(createddate) AS                                         shipped_at, --SADLY WE HAVE TO USE CREATEDDATE AS THE SHIPPING DATE AND JUST HOPE THAT IT WAS CREATED/SHIPPED THE SAME DAY BECAUSE NS DOESN'T STORE SHIPPEDDATE ANYWHERE
                NULL                          AS                                         shipmentcost,
                NULL                          AS                                         is_cancelled,
                shipping.state,
                shipping.country,
                shipping.city,
                COALESCE(tran.CUSTBODY_STORD_CONFIRMATION_ID, tran.CUSTBODY_SHIPMENT_ID) shipment_id,
                NULL                          AS                                         item_id,
                product_id_edw,
                total_quantity
FROM dim.fulfillment fulfill
         CROSS JOIN LATERAL FLATTEN(INPUT =>itemfulfillment_ids) AS if_ids
         LEFT OUTER JOIN staging.ORDER_ITEM_DETAIL staged ON staged.TRANSACTION_ID_NS = if_ids.value
         LEFT OUTER JOIN netsuite.transaction tran ON tran.id = staged.TRANSACTION_ID_NS
         LEFT OUTER JOIN netsuite.itemfulfillmentshippingaddress shipping ON shipping.nkey = tran.SHIPPINGADDRESS
WHERE ARRAY_SIZE(itemfulfillment_ids) > 0


