SELECT DISTINCT --Ok so the main idea for this table is to have it be one row per "transaction" that makes up a fulfillment, no matter how many there may be
				fulfillment_id_edw,
				order_id_edw,
				CONCAT(fulfillment_id_edw, '_', SHIPMENT_ID) AS fulfillment_line_id,
				SHIPMENT_ID,
				SOURCE,
				carrier,
				carrier_service,
				shipdate,
				voided,
				country,
				state,
				city,
				FIRST_VALUE(warehouse_location) OVER ( PARTITION BY fulfillment_id_edw,
					SHIPMENT_ID ORDER BY shipdate ASC)       AS warehouse_location,--Has to be a first_value as one NS IF can have multiple locations on it.
				SUM(quantity) OVER (
					PARTITION BY
						fulfillment_id_edw,
						SHIPMENT_ID
					)                                        AS total_quantity
FROM fact.fulfillment_item_detail
ORDER BY ORDER_ID_EDW DESC
