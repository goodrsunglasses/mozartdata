SELECT DISTINCT fulfillment_id_edw,
				order_id_edw,
				SHIPMENT_ID,
				SOURCE,
				carrier,
				carrier_service,
				shipdate,
				voided,
				country,
				state,
				city,
				SUM(quantity) OVER (
					PARTITION BY
						fulfillment_id_edw,
						SHIPMENT_ID
					) AS total_quantity
FROM fact.fulfillment_item_detail
ORDER BY ORDER_ID_EDW DESC