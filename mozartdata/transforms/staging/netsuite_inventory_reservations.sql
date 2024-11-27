/*
Purpose: show the inventory reservations currently listed in Netsuite.
One row per transaction id?

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )
SELECT--This is basically a raw select of anything and everything relevant for order reservation data based on what I can tell
	tran.id             AS transaction_id_ns,
	   tran.title,
	   tran.createdby,
	   ent.altname,
	   tran.status,
	   transtatus.fullname AS transaction_status,
	   tran.CREATEDDATE,
	   tran.STARTDATE,
	   tran.enddate,
	   tran.saleschannel,
	   chan.name,
	   tran.LASTMODIFIEDBY,
	   tran.LASTMODIFIEDDATE,
	   tran.RECORDTYPE,
	   tran.trandate,
	   tran.source,
	   line.item,
	   line.quantity,
	   line.dayslate,
	   line.FULFILLABLE,
	   line.location,
	   line.ORDERALLOCATIONSTRATEGY,
	   line.REQUESTEDDATE,
	   line.QUANTITYSHIPRECV
FROM netsuite.transaction tran
		 LEFT OUTER JOIN netsuite.transactionline line ON line.transaction = tran.id
		 LEFT OUTER JOIN netsuite.entity ent ON ent.id = tran.CREATEDBY
		 LEFT OUTER JOIN netsuite.saleschannel chan ON chan.id = tran.saleschannel
		 LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
	tran.status = transtatus.id
		AND tran.type = transtatus.trantype
	)
WHERE recordtype = 'orderreservation'
  AND line.item IS NOT NULL--Added this because I wanted to only see the lines that are actually an item