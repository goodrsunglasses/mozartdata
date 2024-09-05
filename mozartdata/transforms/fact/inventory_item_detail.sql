--CREATE OR REPLACE TABLE fact.inventory_item_detail
--COPY GRANTS  as
WITH netsuite_culmative
		 AS (SELECT --the idea with this CTE is to create the culmative quantity after, and before a given inventory transaction, seperated for ease of comprehension
					transaction_id_ns,
					transaction_created_timestamp_pst,
					transaction_date,
					location_name,
					transaction_number_ns,
					sku,
					quantity,
					SUM(quantity) OVER (
						PARTITION BY
							sku,
							location_name
						ORDER BY
							tran_date,transaction_created_timestamp_pst ROWS BETWEEN UNBOUNDED PRECEDING --This is a bit weird, we're ordering by trandate first because it can be backdated-
						-- and is technically more correct, but its not hour/minute specific which can lead to disordering so we use the timestamp also
							AND CURRENT ROW
						)                AS culmative,
					culmative - quantity AS before
			 FROM fact.NETSUITE_INVENTORY_ITEM_DETAIL)
SELECT detail.transaction_id_ns,
	   detail.ORDER_ID_EDW,
	   detail.RECORD_TYPE,
	   detail.channel,
	   NULL      AS reason,
	   detail.sku,
	   detail.plain_name,
	   detail.quantity,
	   before    AS quantity_before,
	   culmative AS quantity_after,
	   detail.location_name,
	   detail.TRANSACTION_CREATED_TIMESTAMP_PST,
	   detail.transaction_date
FROM fact.NETSUITE_INVENTORY_ITEM_DETAIL detail
		 LEFT OUTER JOIN netsuite_culmative culm ON (culm.TRANSACTION_ID_NS = detail.transaction_id_ns AND culm.sku =
																										   detail.sku) --Double join because 1 transaction can and will impact inventory for multiple skus
UNION ALL
SELECT detail.ADJUSTMENT_SEQUENCE,
	   detail.order_id_ns,
	   detail.reason_type,
	   NULL AS channel,
	   detail.reason,
	   detail.sku,
	   detail.DISPLAY_NAME,
	   detail.adjustment_quantity,
	   detail.PREVIOUS_QUANTITY,
	   detail.UPDATED_QUANTITY,
	   detail.LOCATION_NAME_STORD,
	   ADJUSTED_TIMESTAMP,
	   adjusted_date
FROM fact.STORD_INVENTORY_ITEM_DETAIL detail
