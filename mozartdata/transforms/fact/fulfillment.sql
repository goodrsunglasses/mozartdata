WITH stord_line AS (SELECT FULFILLMENT_ID_EDW,
						   ORDER_ID_EDW,
						   SHIPMENT_ID,
						   carrier,
						   carrier_service,
						   shipdate,
						   country,
						   state,
						   city,
						   postal_code,
						   customer_name,
						   addr_line_1,
						   addr_line_2,
						   addr_verification_status,
						   ADDRESS_TYPE,
						   CASE
							   WHEN warehouse_location LIKE 'ATL%' THEN 'ATL'
							   WHEN warehouse_location LIKE 'LAS%' THEN 'LAS'
							   ELSE NULL END AS warehouse_location
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
						city,
						postal_code,
						customer_name,
						addr_line_1,
						addr_line_2
				 FROM fact.FULFILLMENT_LINE
				 WHERE source = 'Shipstation'),
	 ns_info AS (SELECT DISTINCT fulfillment_id_edw,
								 ORDER_ID_EDW,
								 FIRST_VALUE(
										 carrier) -- All of these need to be first_valued as there can be multiple IF's per shipment, and ideally these won't differ however to avoid data splay we handle it via earliest record
										 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC)     AS carrier,
								 FIRST_VALUE(CARRIER_SERVICE)
											 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC) AS CARRIER_SERVICE,
								 FIRST_VALUE(shipdate)
											 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC) AS ship_date,
								 FIRST_VALUE(country)
											 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC) AS country,
								 FIRST_VALUE(state)
											 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC) AS state,
								 FIRST_VALUE(city)
											 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC) AS city,
								 FIRST_VALUE(postal_code)
											 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC) AS postal_code,
								 FIRST_VALUE(customer_name)
											 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC) AS customer_name,
								 FIRST_VALUE(addr_line_1)
											 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC) AS addr_line_1,
								 FIRST_VALUE(addr_line_2)
											 OVER (PARTITION BY FULFILLMENT_ID_EDW ORDER BY SHIPDATE DESC) AS addr_line_2
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
	   fulfill.source_system,
	   CASE WHEN ARRAY_SIZE(itemfulfillment_ids) > 1 THEN TRUE ELSE FALSE END       AS multiple_if_flag,
	   COALESCE(stord.customer_name, ss.customer_name, ns_info.customer_name)       AS customer_name,
	   COALESCE(stord.carrier, ss.CARRIER, ns_info.carrier)                         AS carrier,           --we can use coalesce logic because a given fulfillment_id_edw isn't present in both stord and shipstation (I checked to be sure)
	   COALESCE(stord.carrier_service, ss.carrier_service, ns_info.CARRIER_SERVICE) AS carrier_service,
	   COALESCE(stord.shipdate, ss.shipdate, ns_info.ship_date)                     AS ship_date,
	   COALESCE(stord.country, ss.country, ns_info.country)                         AS country,
	   COALESCE(stord.state, ss.state, ns_info.state)                               AS state,
	   COALESCE(stord.city, ss.city, ns_info.city)                                  AS city,
	   COALESCE(stord.postal_code, ss.postal_code, ns_info.postal_code)             AS postal_code,
	   COALESCE(stord.addr_line_1, ss.addr_line_1, ns_info.addr_line_1)             AS addr_line_1,
	   COALESCE(stord.addr_line_2, ss.addr_line_2, ns_info.addr_line_2)             AS addr_line_2,
	   stord.addr_verification_status,
	   stord.ADDRESS_TYPE,
	   COALESCE(stord.warehouse_location, 'Lagoon')                                 AS warehouse_location,--As of right now it only has logic for either stord ATL or LAS, if thats not the case then it just fills it in as Lagoon, as the asumption is everything else had to go out of there
	   ns_info.customer_name                                                        AS customer_name_ns,
	   ns_info.carrier                                                              AS carrier_ns,
	   ns_info.CARRIER_SERVICE                                                      AS CARRIER_SERVICE_ns,
	   ns_info.ship_date                                                            AS ship_date_ns,
	   ns_info.country                                                              AS country_ns,
	   ns_info.state                                                                AS state_ns,
	   ns_info.city                                                                 AS city_ns,
	   ns_info.postal_code                                                          AS postal_code_ns,
	   ns_info.addr_line_1                                                          AS addr_line_1_ns,
	   ns_info.addr_line_2                                                          AS addr_line_2_ns,
	   aggregates.total_QUANTITY_NS,
	   aggregates.total_QUANTITY_STORD,
	   aggregates.total_QUANTITY_SS

FROM dim.FULFILLMENT fulfill
		 LEFT OUTER JOIN stord_line stord ON (stord.FULFILLMENT_ID_EDW = fulfill.FULFILLMENT_ID_EDW AND
											  stord.SHIPMENT_ID = fulfill.SOURCE_SYSTEM_ID)
		 LEFT OUTER JOIN ss_line ss ON (ss.FULFILLMENT_ID_EDW = fulfill.FULFILLMENT_ID_EDW AND
										ss.SHIPMENT_ID = fulfill.SOURCE_SYSTEM_ID)
		 LEFT OUTER JOIN aggregates ON aggregates.FULFILLMENT_ID_EDW = fulfill.FULFILLMENT_ID_EDW
		 LEFT OUTER JOIN ns_info ON ns_info.FULFILLMENT_ID_EDW = fulfill.FULFILLMENT_ID_EDW