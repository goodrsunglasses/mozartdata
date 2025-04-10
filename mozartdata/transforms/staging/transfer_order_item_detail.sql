SELECT
  tran.id AS transaction_id_ns,
  tran.tranid as transaction_number_ns,
  CONCAT(tran.tranid, '_', tran.id, '_', tranlineship.item) AS transfer_order_item_detail_id,
  date(tran.trandate) as transaction_date,
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS transaction_created_timestamp_pst,
  DATE(
    CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate)
  ) AS transaction_created_date_pst,
  tran.recordtype AS record_type,
  transtatus.name as status,
  transtatus.fullname as full_status,
  tran.memo,
  case when tran.firmed = 'T' then true else false end as firmed_flag,
  case when tran.useitemcostastransfercost = 'T' then true else false end as use_item_cost_flag,
  i.name as incoterm,
  tran.custbodyamazon_shipment_id as amazon_shipment_id,
  date(tran.shipdate) as ship_by_date,
  tranlineship.itemtype AS item_type,
  coalesce(item.itemid, cast(tranlineship.item as string)) AS product_id_edw,
  tranlineship.item AS item_id_ns,
  item.itemid as sku,
  SUM(ABS(tranlineship.quantity)) AS total_quantity,
  SUM(ABS(tranlineship.quantitycommitted)) as quantity_committed,
  SUM(ABS(tranlineship.quantityallocated)) as quantity_allocated_supply,
  SUM(ABS(tranlineship.quantitypicked)) quantity_picked,
  SUM(ABS(tranlineship.quantitypacked)) quantity_packed,
  SUM(ABS(tranlinerec.quantityshiprecv)) quantity_received,
  SUM(ABS(tranlineship.quantitybackordered)) quantity_backordered,
  SUM(ABS(coalesce(tranlineship.quantitydemandallocated,0))) as quantity_allocated_demand,
  tranlineship.location as shipping_location,
  tranlinerec.location as receiving_location,
  date(tranlineship.requesteddate) as requested_date,
  date(tranlineship.expectedreceiptdate) as expected_receipt_date,
  date(tranlineship.expectedshipdate) as expected_ship_date,
  tranlineship.dayslate as days_late,
  oas.name as allocation_strategy
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranlineship
    ON tranlineship.transaction = tran.id
    and tranlineship.transferorderitemlineid is not null
    and tranlineship.transactionlinetype = 'SHIPPING'
  LEFT OUTER JOIN netsuite.transactionline tranlinerec
    ON tranlinerec.transaction = tran.id
    and tranlinerec.transferorderitemlineid is not null
    and tranlinerec.transactionlinetype = 'RECEIVING'
    and tranlineship.item = tranlinerec.item
  LEFT OUTER JOIN netsuite.orderallocationstrategy oas
    ON oas.id = tranlineship.orderallocationstrategy
  LEFT OUTER JOIN netsuite.incoterm i
    ON tran.incoterm = i.id
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
  LEFT OUTER JOIN netsuite.item item ON item.id = tranlineship.item
WHERE
  tran.recordtype = 'transferorder'
  AND tranlineship.itemtype = 'InvtPart'
group by all

