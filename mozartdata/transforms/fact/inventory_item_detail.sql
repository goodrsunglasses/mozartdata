--CREATE OR REPLACE TABLE fact.inventory_item_detail
--COPY GRANTS  as
SELECT detail.transaction_id_ns,
	   detail.ORDER_ID_EDW,
	   detail.RECORD_TYPE,
	   detail.channel,
	   detail.CUSTOMER_CATEGORY,
	   detail.model,
 detail.location_name,
detail.TRANSACTION_CREATED_TIMESTAMP_PST,
 detail.TRANSACTION_CREATED_DATE_PST
FROM fact.NETSUITE_INVENTORY_ITEM_DETAIL detail

select * from fact.STORD_INVENTORY_ITEM_DETAIL where DISPLAY_NAME = 'Hooked on Onyx' order by ADJUSTED_TIMESTAMP desc