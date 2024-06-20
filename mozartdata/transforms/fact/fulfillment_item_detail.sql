CREATE OR REPLACE TABLE fact.fulfillment_item_detail
    COPY GRANTS as
SELECT fulfillment_id_edw,
	   fulfill.ORDER_ID_EDW,
	   'Shipstation'                           AS source,
	   carriercode                             AS carrier,
	   servicecode                             AS carrier_service,
	   shipdate,
-- 	   shipmentcost                            AS shipment_cost, Gabby said no
	   voided,
	   NULL                                    AS warehouse_location,
	   shipto:NAME::STRING                     AS customer_name,
	   shipto:STATE::STRING                    AS state,
	   shipto:COUNTRY::STRING                  AS country,
	   shipto:CITY::STRING                     AS city,
	   shipto:POSTALCODE::STRING               AS postal_code,
	   shipto:STREET1::STRING                  AS addr_line_1,
	   shipto:STREET2::STRING                  AS addr_line_2,
	   NULL                                    AS addr_verification_status,
	   NULL                                    AS ADDRESS_TYPE,
	   TO_CHAR(items.shipmentid)               AS shipment_id,
	   flattened_items.value:PRODUCTID::STRING AS item_id,
	   product.sku,
	   flattened_items.value:NAME::STRING      AS product_name,
	   flattened_items.value:QUANTITY::INTEGER AS quantity
FROM dim.fulfillment fulfill
		 LEFT OUTER JOIN shipstation_portable.shipstation_shipment_items_8589936627 items
						 ON TO_CHAR(items.shipmentid) = fulfill.source_system_id
		 CROSS JOIN LATERAL FLATTEN(INPUT => items.shipmentitems) AS flattened_items
		 LEFT OUTER JOIN dim.product product
						 ON (product.item_id_shipstation = flattened_items.value:PRODUCTID::INTEGER OR
							 product.sku = flattened_items.value:SKU::STRING)
WHERE source_system = 'Shipstation'
--Stord
UNION ALL
SELECT DISTINCT fulfillment_id_edw,
				fulfill.ORDER_ID_EDW,
				'Stord'                                                                AS source,
				stord.carrier_name,
				stord.carrier_service_method,
				stord.shipped_at,
-- 	   NULL                                                                   AS shipmentcost,
				is_canceled,
				sla_lines.value:FACILITY_ACTIVITY:FACILITY_ALIAS                       AS facility_alias,
				orders.destination_address:NAME::STRING                                AS customer_name,
				orders.destination_address:NORMALIZED_COUNTRY_SUBDIVISION_CODE::STRING AS state,
				orders.destination_address:NORMALIZED_COUNTRY_CODE::STRING             AS country,
				orders.destination_address:NORMALIZED_LOCALITY::STRING                 AS city,
				orders.destination_address:NORMALIZED_POSTAL_CODE::STRING              AS postal_code,
				orders.destination_address:NORMALIZED_LINE1::STRING                    AS addr_line_1,
				orders.destination_address:NORMALIZED_LINE2::STRING                    AS addr_line_2,
				orders.destination_address:VERIFICATION_STATUS::STRING                    addr_verification_status,
				orders.destination_address:ADDRESS_TYPE::STRING                        AS ADDRESS_TYPE,
				shipment_confirmation_id                                               AS shipment_id,
				flattened_items.value:ITEM_ID::STRING                                  AS item_id,
				product.sku,
				stordprod.name,
				flattened_items.value:QUANTITY::INTEGER                                AS quantity
FROM dim.fulfillment fulfill
		 LEFT OUTER JOIN stord.stord_shipment_confirmations_8589936822 stord
						 ON stord.shipment_confirmation_id = fulfill.source_system_id
		 LEFT OUTER JOIN stord.stord_sales_orders_8589936822 orders ON orders.order_id = stord.order_id
		 CROSS JOIN LATERAL FLATTEN(INPUT => stord.SHIPMENT_CONFIRMATION_LINE_ITEMS) AS flattened_items
		 CROSS JOIN LATERAL FLATTEN(INPUT => orders.SLA_SALES_ORDER_LINES) AS sla_lines
		 LEFT OUTER JOIN dim.product product ON product.item_id_stord = flattened_items.value:ITEM_ID::STRING
		 LEFT OUTER JOIN stord.STORD_PRODUCTS_8589936822 stordprod
						 ON stordprod.id = flattened_items.value:ITEM_ID::STRING --Joining here because I want the name of the product because sometimes it doesn't exist in NS
WHERE source_system = 'Stord'
--Netsuite
UNION ALL
SELECT DISTINCT --adding just in case because NS joins can be funky and I don't want any duplicate lines becase one custom field has two values or something
				fulfill.FULFILLMENT_ID_EDW,
				fulfill.ORDER_ID_EDW,
				'Netsuite'                    AS source,
				custbody_shipstation_carrier_code,
				custbody_service_code,
				TO_TIMESTAMP_NTZ(createddate) AS shipped_at, --SADLY WE HAVE TO USE CREATEDDATE AS THE SHIPPING DATE AND JUST HOPE THAT IT WAS CREATED/SHIPPED THE SAME DAY BECAUSE NS DOESN'T STORE SHIPPEDDATE ANYWHERE
-- 				NULL                          AS                                         shipmentcost,
				NULL                          AS is_cancelled,
				staged.location,
				shipping.ADDRESSEE,
				shipping.state,
				shipping.country,
				shipping.city,
				shipping.zip                  AS postal_code,
				shipping.ADDR1,
				shipping.ADDR2,
				NULL                          AS addr_verification_status,
				NULL                          AS ADDRESS_TYPE,
				TO_CHAR(staged.transaction_id_ns),
				NULL                          AS item_id,
				product.sku,
				PLAIN_NAME,
				total_quantity
FROM dim.fulfillment fulfill
		 CROSS JOIN LATERAL FLATTEN(INPUT =>itemfulfillment_ids) AS if_ids
		 LEFT OUTER JOIN staging.ORDER_ITEM_DETAIL staged ON staged.TRANSACTION_ID_NS = if_ids.value
		 LEFT OUTER JOIN dim.product product ON product.item_id_ns = staged.ITEM_ID_NS
		 LEFT OUTER JOIN netsuite.transaction tran ON tran.id = staged.TRANSACTION_ID_NS
		 LEFT OUTER JOIN netsuite.itemfulfillmentshippingaddress shipping ON shipping.nkey = tran.SHIPPINGADDRESS
WHERE ARRAY_SIZE(itemfulfillment_ids) > 0
  AND PLAIN_NAME NOT IN ('Shipping', 'Tax')
