WITH stord_line AS (SELECT FULFILLMENT_ID_EDW,
						   ORDER_ID_EDW,
						   SHIPMENT_ID,
						   carrier,
						   carrier_service,
						   shipdate,
						   country,
						   state,
						   city,
						   CASE
							   WHEN warehouse_location LIKE 'ATL%' THEN 'ATL'
							   WHEN warehouse_location LIKE 'LAS%' THEN 'LAS'
							   ELSE Null END AS warehouse_location
					FROM fact.FULFILLMENT_LINE
					WHERE source = 'Stord'),
	 ss_line AS (SELECT FULFILLMENT_ID_EDW,
						ORDER_ID_EDW,
						SHIPMENT_ID,
						carrier,
						carrier_service,
						shipdate,
						country,
						state,
						city
				 FROM fact.FULFILLMENT_LINE
				 WHERE source = 'Shipstation'),
	 ns_info AS (SELECT *
				 FROM fact.FULFILLMENT_LINE
				 WHERE source = 'Netsuite'),
	 aggregates AS (SELECT FULFILLMENT_ID_EDW,
						   SUM(QUANTITY_NS)    AS total_QUANTITY_NS,
						   SUM(QUANTITY_STORD) AS total_QUANTITY_STORD,
						   SUM(QUANTITY_SS)    AS total_QUANTITY_SS
					FROM fact.FULFILLMENT_ITEM
					GROUP BY FULFILLMENT_ID_EDW)
SELECT fulfill.FULFILLMENT_ID_EDW,
	   fulfill.ORDER_ID_EDW,
	   COALESCE(stord.carrier, ss.CARRIER)                 AS carrier, --we can use coalesce logic because a given fulfillment_id_edw isn't present in both stord and shipstation (I checked to be sure)
	   COALESCE(stord.carrier_service, ss.carrier_service) AS carrier_service,
	   COALESCE(stord.shipdate, ss.shipdate)               AS shipdate,
	   COALESCE(stord.country, ss.country)                 AS country,
	   COALESCE(stord.state, ss.state)                     AS state,
	   COALESCE(stord.city, ss.city)                       AS city,
	   coalesce(stord.warehouse_location,'Lagoon')as warehouse_location,--As of right now it only has logic for either stord ATL or LAS, if thats not the case then it just fills it in as Lagoon, as the asumption is everything else had to go out of there
	   aggregates.total_QUANTITY_NS,
	   aggregates.total_QUANTITY_STORD,
	   aggregates.total_QUANTITY_SS

FROM dim.FULFILLMENT fulfill
		 LEFT OUTER JOIN stord_line stord ON (stord.FULFILLMENT_ID_EDW = fulfill.FULFILLMENT_ID_EDW AND
											  stord.SHIPMENT_ID = fulfill.SOURCE_SYSTEM_ID)
		 LEFT OUTER JOIN ss_line ss ON (ss.FULFILLMENT_ID_EDW = fulfill.FULFILLMENT_ID_EDW AND
										ss.SHIPMENT_ID = fulfill.SOURCE_SYSTEM_ID)
		 LEFT OUTER JOIN aggregates ON aggregates.FULFILLMENT_ID_EDW = fulfill.FULFILLMENT_ID_EDW