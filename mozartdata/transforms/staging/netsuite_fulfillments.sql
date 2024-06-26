CREATE OR REPLACE TABLE staging.netsuite_fulfillments
	COPY GRANTS AS
SELECT --The idea for this table is to get a simple staging area for the myriad of tracking and fulfillment related info SPECIFICALLY coming out of Netsuite, for easy use later in the pipeline
	   tran.id                           AS transaction_id_ns,
	   tran.custbody_goodr_shopify_order AS order_id_ns,
	   tracking.trackingnumber,
	   CONCAT(
			   tran.custbody_goodr_shopify_order,
			   '_',
			   tracking.trackingnumber
	   )                                    fulfillment_id_edw,
	   'Netsuite'                        AS source,
	   tran.actualshipdate,
	   tran.BILLINGADDRESS,
	   tran.billingstatus,
	   tran.closedate,
	   tran.createdby,
	   tran.CREATEDDATE,
	   tran.cseg7,
	   tran.custbody_label_tracking_number,
	   tran.custbody_readyforedi,
	   tran.entity,
	   tran.LASTMODIFIEDBY,
	   tran.LASTMODIFIEDDATE,
	   tran.ordpicked,
	   tran.PRINTEDPICKINGTICKET,
	   tran.RECORDTYPE,
	   tran.SHIPCARRIER,
	   tran.SHIPPINGADDRESS,
	   tran.status,
	   tran.TRACKINGNUMBERLIST,
	   tran.trandate,
	   tran.TOBEPRINTED,
	   tran.custbodyrfs_shipped_at,
	   tran.custbodyrfs_carrier,
	   tran.custbodyrfs_shipping_url,
	   tran.custbodyrfs_carrier_service,
	   tran.custbodyrfs_shipped_by,
	   shipping.ADDRESSEE,
	   shipping.state,
	   shipping.country,
	   shipping.city,
	   shipping.zip                      AS postal_code,
	   shipping.ADDR1,
	   shipping.ADDR2,
	   tran.custbody_shipstation_carrier_code,
	   tran.custbody_service_code
FROM netsuite.transaction tran
		 LEFT OUTER JOIN netsuite.trackingnumbermap map
						 ON map.transaction = tran.id
		 LEFT OUTER JOIN netsuite.trackingnumber tracking ON tracking.id = map.trackingnumber
		 LEFT OUTER JOIN netsuite.itemfulfillmentshippingaddress shipping ON shipping.nkey = tran.SHIPPINGADDRESS
WHERE recordtype = 'itemfulfillment'
  AND fulfillment_id_edw IS NOT NULL--Added because the fulfillment schema needs tracking numbers to Identify fulfillments

