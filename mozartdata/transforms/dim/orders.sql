WITH
  ns_salesrev AS (
    SELECT
      transaction,
      MAX(product_sales) AS product_sales,
      MAX(ship_rate) AS ship_rate
    FROM
      (
        SELECT
          transaction,
          CASE
            WHEN itemtype = 'InvtPart' THEN -1 * (SUM(netamount))
            ELSE NULL
          END AS product_sales,
          CASE
            WHEN itemtype = 'ShipItem' THEN MAX(rate)
            ELSE NULL
          END AS ship_rate
        FROM
          netsuite.transactionline
        GROUP BY
          transaction,
          itemtype
      )
    GROUP BY
      transaction
  )
SELECT DISTINCT
  tran.id AS ns_id,
  transtatus.fullname AS tran_status,
  tran.tranid AS ns_tran_id,
  channel.name AS channel,
  tran.recordtype AS type,
  -- tran.custbody_goodr_total_order_quantity,
  tran.custbody_goodr_po_number AS po_number,
  tran.startDate,
  tran.enddate,
  product_sales,
  ship_rate,
  tran.estgrossprofit AS gross_profit,
  tran.estgrossprofitpercent AS profit_percent
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
  left outer join ns_salesrev on ns_salesrev.transaction=tran.id
WHERE
  tran.recordtype IN (
    'salesorder',
    'cashsale',
    'invoice',
    'cashrefund',
    'itemfulfillment'
  )