/*
Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
  root_table as (
    select
        *
    from
        mozart.pipeline_root_table
    ),
base  AS
(
  SELECT
    tran.id                                                                 AS transaction_id_ns
  , tran.tranid                                                             AS transaction_number_ns
  , CONCAT(tran.tranid, '_', tran.id, '_', tranlineship.item, '_', tranlineship.id)  AS transfer_order_item_detail_id
  , DATE(tran.trandate)                                                     AS transaction_date
  , tran.recordtype                                                         AS record_type
  , transtatus.name                                                         AS status
  , transtatus.fullname                                                     AS full_status
  , tran.memo
  , CASE WHEN tran.firmed = 'T' THEN TRUE ELSE FALSE END                    AS firmed_flag
  , CASE WHEN tran.useitemcostastransfercost = 'T' THEN TRUE ELSE FALSE END AS use_item_cost_flag
  , i.name                                                                  AS incoterm
  , tran.custbodyamazon_shipment_id                                         AS shipment_id_amazon
  , DATE(tran.custbodyeta_date)                                             AS ship_by_date
  , tranlineship.createdfrom                                                AS created_from_transaction_id_ns
  , tranlineship.itemtype                                                   AS item_type
  , tranlineship.id                                                         AS transaction_line_id_ns
  , COALESCE(item.itemid, CAST(tranlineship.item AS string))                AS product_id_edw
  , tranlineship.item                                                       AS item_id_ns
  , item.itemid                                                             AS sku
  , SUM(ABS(tranlineship.quantity))                                         AS total_quantity
  , SUM(ABS(tranlineship.quantitycommitted))                                AS quantity_committed
  , SUM(ABS(tranlineship.quantityallocated))                                AS quantity_allocated_supply
  , SUM(ABS(tranlineship.quantitypicked))                                   AS quantity_picked
  , SUM(ABS(tranlineship.quantitypacked))                                   AS quantity_packed
  , SUM(ABS(tranlinerec.quantityshiprecv))                                  AS quantity_received
  , SUM(ABS(tranlineship.quantitybackordered))                              AS quantity_backordered
  , SUM(ABS(COALESCE(tranlineship.quantitydemandallocated, 0)))             AS quantity_allocated_demand
  , tranlineship.location                                                   AS shipping_location
  , tranlinerec.location                                                    AS receiving_location
  , DATE(tranlineship.requesteddate)                                        AS requested_date
  , DATE(tranlineship.expectedreceiptdate)                                  AS expected_receipt_date
  , DATE(tranlineship.expectedshipdate)                                     AS expected_ship_date
  , tranlineship.dayslate                                                   AS days_late
  , oas.name                                                                AS allocation_strategy
  FROM
    netsuite.transaction tran
    LEFT OUTER JOIN netsuite.transactionline tranlineship
                    ON tranlineship.transaction = tran.id
                      AND
                       ((tran.recordtype = 'transferorder' AND tranlineship.transferorderitemlineid IS NOT NULL AND
                         tranlineship.transactionlinetype = 'SHIPPING')
                         OR (tran.recordtype != 'transferorder' AND tranlineship.custcol4 is not null))
    LEFT OUTER JOIN netsuite.transactionline tranlinerec
                    ON tranlinerec.transaction = tran.id
                     AND
                       (tran.recordtype = 'transferorder' AND tranlineship.transferorderitemlineid = tranlinerec.transferorderitemlineid AND
                         tranlinerec.transactionlinetype = 'RECEIVING')
                      AND tranlineship.item = tranlinerec.item
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
    tran.recordtype IN ('transferorder', 'itemfulfillment', 'itemreceipt')
  GROUP BY ALL
  )
, final AS (
  SELECT
    transaction_number_ns AS transfer_order_number_ns
  , b.transaction_id_ns AS transfer_order_transaction_id_ns
  , b.*
  FROM
    base b
  WHERE
    b.record_type = 'transferorder'
  UNION ALL
  SELECT distinct
    t.transaction_number_ns AS transfer_order_number_ns
  , t.transaction_id_ns AS transfer_order_transaction_id_ns
  , b.*
  FROM
    base b
    INNER JOIN
      base t
      ON b.created_from_transaction_id_ns = t.transaction_id_ns
        AND t.record_type = 'transferorder'
        AND b.item_id_ns = t.item_id_ns
  ORDER BY transaction_id_ns
  )

SELECT *
FROM
  final
