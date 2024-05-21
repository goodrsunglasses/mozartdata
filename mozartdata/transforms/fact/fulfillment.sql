WITH stord_info AS (SELECT FULFILLMENT_ID_EDW,
						   ORDER_ID_EDW,
						   carrier,
						   carrier_service,
						   shipdate,
						   country,
						   state,
						   city,
						   CASE
							   WHEN warehouse_location LIKE 'ATL%' THEN 'ATL'
							   WHEN warehouse_location LIKE 'LAS%' THEN 'LAS'
							   ELSE NULL END AS warehouse_location
					FROM fact.FULFILLMENT_LINE
					WHERE source = 'Stord'),
	ss_info as( select FULFILLMENT_ID_EDW,
						   ORDER_ID_EDW,
						   carrier,
						   carrier_service,
						   shipdate,
						   country,
						   state,
						   city
						   FROM fact.FULFILLMENT_LINE
					WHERE source = 'Shipstation'),
ns_info as ( select *
						   FROM fact.FULFILLMENT_LINE
					WHERE source = 'Netsuite')
select fulfill.FULFILLMENT_ID_EDW,fulfill.ORDER_ID_EDW from dim.FULFILLMENT fulfill