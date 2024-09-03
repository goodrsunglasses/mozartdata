--CREATE OR REPLACE TABLE fact.netsuite_inventory_reservations
--  COPY GRANTS  as
SELECT --The idea I have here is to strip away the confusing ID fields from the staging table, and further to join to the dim tables we have to further flesh this table out
	   reserv.transaction_id_ns,
	   reserv.title                                                AS transaction_name,
	   reserv.altname                                              AS created_by,
	   reserv.name                                                 AS sales_channel_ns,
	   DATE(reserv.trandate)                                       AS tran_date,--from here on out using date() because every single one of these is imported via CSV and all the date fields are not timestamped besides '00:00:00.000000000 +00:00'
	   reserv.transaction_status,
	   date(reserv.CREATEDDATE) as created_date,
	   DATE(reserv.STARTDATE)                                      AS start_date,
	   DATE(reserv.enddate)                                        AS end_date,
	   loc.name                                                    AS location_name,
	   reserv.item                                                 AS item_id_ns,
	   prod.sku,
	   prod.DISPLAY_NAME,
	   reserv.quantity,
	   reserv.QUANTITYSHIPRECV                                     AS QUANTITY_SHIP_REC,
	   reserv.dayslate                                             AS days_late,
	   CASE WHEN reserv.FULFILLABLE = 'T' THEN TRUE ELSE FALSE END AS fulfillable,
	   reserv.ORDERALLOCATIONSTRATEGY                              AS order_allocation_strategy,
	   DATE(reserv.REQUESTEDDATE)                                  AS REQUESTED_DATE,
	   reserv.source,
	   DATE(reserv.LASTMODIFIEDDATE)                               AS LAST_MODIFIED_DATE
FROM staging.netsuite_inventory_reservations reserv
		 LEFT OUTER JOIN dim.product prod ON prod.item_id_ns = reserv.item
		 LEFT OUTER JOIN dim.location loc ON loc.LOCATION_ID_NS = reserv.location

