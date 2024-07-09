SELECT prod.sku,
	   ns.location,
	   loc.name,
	   ns.binnumber,
	   bin.BINNUMBER as bin_name,
	   ns.QUANTITYAVAILABLE,
	   ns.QUANTITYONHAND,
	   ns.QUANTITYPICKED,
	   CONVERT_TIMEZONE('America/Los_Angeles', ns._FIVETRAN_SYNCED)       AS FIVETRAN_SYNC_TIME_PST,
	   DATE(CONVERT_TIMEZONE('America/Los_Angeles', ns._FIVETRAN_SYNCED)) AS fivetran_snapshot_date_pst,
	   --everything past here is included for posterity, as often we seem to need the most nonsensical fields for one specific request
	   ns.COMMITTEDQTYPERLOCATION,
	   ns.COMMITTEDQTYPERSERIALLOTNUMBER,
	   ns.COMMITTEDQTYPERSERIALLOTNUMBERLOCATION
FROM staging.NETSUITE_INVENTORY ns
		 LEFT OUTER JOIN dim.product prod ON prod.ITEM_ID_NS = ns.item
		 LEFT OUTER JOIN dim.location loc ON loc.LOCATION_ID_NS = ns.location
		 LEFT OUTER JOIN netsuite.bin bin ON bin.id = ns.binnumber