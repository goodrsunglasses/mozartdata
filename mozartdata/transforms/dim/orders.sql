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
SELECT
  tran.id as ns_id,
  tran.tranid as ns_tran_id,
  product_sales,
  ship_rate,
  tran.estgrossprofit AS gross_profit,
  tran.estgrossprofitpercent AS profit_percent
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN ns_salesrev ON ns_salesrev.transaction = tran.id