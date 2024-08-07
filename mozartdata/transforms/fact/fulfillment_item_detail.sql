WITH so_locations AS (--The idea for this CTE is that based on cross comparison requests there was a severe need to compare the fulfillment records of all systems, to the original "Parent" in NS
	SELECT DISTINCT ORDER_ID_EDW,
					item_id_ns,
					plain_name,
					TRANSACTION_CREATED_DATE_PST,
					full_status,
					TOTAL_QUANTITY,
					QUANTITY_BACKORDERED,
					location
	FROM fact.ORDER_ITEM_DETAIL
	WHERE RECORD_TYPE = 'salesorder'
	  AND PLAIN_NAME NOT IN ('Shipping', 'Tax', 'Discount', 'Defectives/Damaged'))
SELECT fulfillment_id_edw,
	   fulfill.ORDER_ID_EDW,
	   fulfill.TRACKING_NUMBER,
	   'Shipstation'                             AS source,
	   carriercode                               AS carrier,
	   servicecode                               AS carrier_service,
  	   shipdate                                  AS ship_date,
-- 	   shipmentcost                            AS shipment_cost, Gabby said no
	   NULL                                      AS order_status,
	   voided,
	   NULL                                      AS warehouse_location,
	   shipto:NAME::STRING                       AS customer_name,
	   shipto:STATE::STRING                      AS state,
	   shipto:COUNTRY::STRING                    AS country,
	   shipto:CITY::STRING                       AS city,
	   shipto:POSTALCODE::STRING                 AS postal_code,
	   shipto:STREET1::STRING                    AS addr_line_1,
	   shipto:STREET2::STRING                    AS addr_line_2,
	   NULL                                      AS addr_verification_status,
	   NULL                                      AS ADDRESS_TYPE,
	   TO_CHAR(items.shipmentid)                 AS shipment_id,
	   flattened_items.value:PRODUCTID::STRING   AS item_id,
	   product.sku,
	   flattened_items.value:NAME::STRING        AS product_name,
	   flattened_items.value:QUANTITY::INTEGER   AS quantity,
	   so_locations.TRANSACTION_CREATED_DATE_PST AS parent_created_date,
	   so_locations.FULL_STATUS                  AS parent_status,
	   so_locations.TOTAL_QUANTITY               AS parent_quantity,
	   so_locations.QUANTITY_BACKORDERED         AS parent_backordered_quantity,
	   so_locations.location                     AS parent_item_location
FROM dim.fulfillment fulfill
		 LEFT OUTER JOIN shipstation_portable.shipstation_shipment_items_8589936627 items
						 ON TO_CHAR(items.shipmentid) = fulfill.source_system_id
		 CROSS JOIN LATERAL FLATTEN(INPUT => items.shipmentitems) AS flattened_items
		 LEFT OUTER JOIN dim.product product
						 ON (product.item_id_shipstation = flattened_items.value:PRODUCTID::INTEGER OR
							 product.sku = flattened_items.value:SKU::STRING)
		 LEFT OUTER JOIN so_locations ON (so_locations.ORDER_ID_EDW = fulfill.ORDER_ID_EDW AND
										  product.ITEM_ID_NS = so_locations.ITEM_ID_NS)
WHERE source_system = 'Shipstation'
--Stord
UNION ALL
SELECT DISTINCT fulfillment_id_edw,
				fulfill.ORDER_ID_EDW,
				fulfill.TRACKING_NUMBER,
				'Stord'                                                                AS source,
				stord.carrier_name,
				stord.carrier_service_method,
				stord.shipped_at,
-- 	   NULL                                                                   AS shipmentcost,
				orders.status                                                          AS order_status,      --Adding this because quite often we want to sort by the status of the original sales order that created a shipment, not the shipment status, esp for splits
				is_canceled,
				CASE
					WHEN stord.facility_id = '4155f00a-e3d9-45c0-84b3-7a03d02080fb' THEN 'ATLs001'
					WHEN stord.facility_id = '12156b5c-23de-48b8-b29d-521414f912e2' THEN 'LASs002'
					ELSE NULL END                                                      AS warehouse_location,--Had to adjust this as before I was joining to the Stord Sales Orders SLA Line which isn't shipment specific
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
				flattened_items.value:QUANTITY::INTEGER                                AS quantity,
				so_locations.TRANSACTION_CREATED_DATE_PST                              AS parent_created_date,
				so_locations.FULL_STATUS                                               AS parent_status,
				so_locations.TOTAL_QUANTITY                                            AS parent_quantity,
				so_locations.QUANTITY_BACKORDERED                                      AS parent_backordered_quantity,
				so_locations.location                                                  AS parent_item_location
FROM dim.fulfillment fulfill
		 LEFT OUTER JOIN stord.stord_shipment_confirmations_8589936822 stord
						 ON stord.shipment_confirmation_id = fulfill.source_system_id
		 LEFT OUTER JOIN stord.stord_sales_orders_8589936822 orders ON orders.order_id = stord.order_id
		 CROSS JOIN LATERAL FLATTEN(INPUT => stord.SHIPMENT_CONFIRMATION_LINE_ITEMS) AS flattened_items
		 LEFT OUTER JOIN dim.product product ON product.item_id_stord = flattened_items.value:ITEM_ID::STRING
		 LEFT OUTER JOIN stord.STORD_PRODUCTS_8589936822 stordprod
						 ON stordprod.id = flattened_items.value:ITEM_ID::STRING --Joining here because I want the name of the product because sometimes it doesn't exist in NS
		 LEFT OUTER JOIN so_locations ON (so_locations.ORDER_ID_EDW = fulfill.ORDER_ID_EDW AND
										  product.ITEM_ID_NS = so_locations.ITEM_ID_NS)
WHERE source_system = 'Stord'
--Netsuite
UNION ALL
SELECT DISTINCT --adding just in case because NS joins can be funky and I don't want any duplicate lines becase one custom field has two values or something
				fulfill.FULFILLMENT_ID_EDW,
				fulfill.ORDER_ID_EDW,
				fulfill.TRACKING_NUMBER,
				'Netsuite'                                                                           AS source,
				COALESCE(nsfulfill.CUSTBODYRFS_CARRIER, nsfulfill.custbody_shipstation_carrier_code) AS carrier_name,
				COALESCE(nsfulfill.CUSTBODYRFS_CARRIER_service, nsfulfill.custbody_service_code)     AS carrier_service,
				TO_TIMESTAMP_NTZ(COALESCE(nsfulfill.CUSTBODYRFS_SHIPPED_AT, createddate))            AS shipped_at, --SADLY WE HAVE TO USE CREATEDDATE AS THE SHIPPING DATE AND JUST HOPE THAT IT WAS CREATED/SHIPPED THE SAME DAY BECAUSE NS DOESN'T STORE SHIPPEDDATE ANYWHERE
-- 				NULL                          AS                                         shipmentcost,
				NULL                                                                                 AS order_status,
				NULL                                                                                 AS is_cancelled,
				TO_CHAR(staged.location),
				nsfulfill.ADDRESSEE,
				nsfulfill.state,
				nsfulfill.country,
				nsfulfill.city,
				nsfulfill.postal_code,
				nsfulfill.ADDR1,
				nsfulfill.ADDR2,
				NULL                                                                                 AS addr_verification_status,
				NULL                                                                                 AS ADDRESS_TYPE,
				TO_CHAR(staged.transaction_id_ns),
				NULL                                                                                 AS item_id,
				product.sku,
				staged.PLAIN_NAME,
				staged.total_quantity,
				so_locations.TRANSACTION_CREATED_DATE_PST                                            AS parent_created_date,
				so_locations.FULL_STATUS                                                             AS parent_status,
				so_locations.TOTAL_QUANTITY                                                          AS parent_quantity,
				so_locations.QUANTITY_BACKORDERED                                                    AS parent_backordered_quantity,
				so_locations.location                                                                AS parent_item_location
FROM dim.fulfillment fulfill
		 CROSS JOIN LATERAL FLATTEN(INPUT =>itemfulfillment_ids) AS if_ids
		 LEFT OUTER JOIN staging.NETSUITE_FULFILLMENTS nsfulfill ON nsfulfill.TRANSACTION_ID_NS = if_ids.value
		 LEFT OUTER JOIN staging.ORDER_ITEM_DETAIL staged ON staged.TRANSACTION_ID_NS = nsfulfill.TRANSACTION_ID_NS
		 LEFT OUTER JOIN dim.product product ON product.item_id_ns = staged.ITEM_ID_NS
		 LEFT OUTER JOIN so_locations ON (so_locations.ORDER_ID_EDW = fulfill.ORDER_ID_EDW AND
										  product.ITEM_ID_NS = so_locations.ITEM_ID_NS)
WHERE ARRAY_SIZE(itemfulfillment_ids) > 0
  AND staged.PLAIN_NAME NOT IN ('Shipping', 'Tax')