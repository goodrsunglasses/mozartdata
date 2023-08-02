WITH
  ns_salesorder AS (
    SELECT DISTINCT
      nestsales.id,
      channel.name,
      order_num,
      MAX(product_rate) OVER (
        PARTITION BY
          order_num
      ) AS product_rate,
      MAX(total_product_amount) OVER (
        PARTITION BY
          order_num
      ) AS total_product_amount,
      MAX(ship_rate) OVER (
        PARTITION BY
          order_num
      ) AS ship_rate,
      MAX(total_quantity) OVER (
        PARTITION BY
          order_num
      ) AS total_quantity,
      tran.estgrossprofit AS gross_profit,
      tran.estgrossprofitpercent AS profit_percent,
      tran.totalcostestimate
    FROM
      (
        SELECT
          tran.id,
          tran.custbody_goodr_shopify_order order_num,
          CASE
            WHEN tranline.itemtype = 'InvtPart' THEN (SUM(rate))
            ELSE NULL
          END AS product_rate,
          CASE
            WHEN tranline.itemtype = 'InvtPart' THEN -1 * (SUM(netamount))
            ELSE NULL
          END AS total_product_amount,
          CASE
            WHEN tranline.itemtype = 'InvtPart' THEN -1 * (SUM(quantity))
            ELSE NULL
          END AS total_quantity,
          CASE
            WHEN tranline.itemtype = 'ShipItem' THEN MAX(rate)
            ELSE NULL
          END AS ship_rate
        FROM
          netsuite.transactionline tranline
          LEFT OUTER JOIN netsuite.transaction tran ON tran.id = tranline.transaction
        WHERE
          tran.recordtype = 'salesorder'
        GROUP BY
          itemtype,
          tran.id,
          order_num
      ) AS nestsales
      LEFT OUTER JOIN netsuite.transaction tran ON tran.id = nestsales.id
      LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
    WHERE
      order_num = 'EMP-7200'
  ),
  ns_cashsale AS (
    SELECT
      order_num,
      MAX(product_sales) AS product_sales,
      MAX(ship_rate) AS ship_rate
    FROM
      (
        SELECT
          tran.custbody_goodr_shopify_order order_num,
        FROM
          netsuite.transactionline tranline
          LEFT OUTER JOIN netsuite.transaction tran ON tran.id = tranline.transaction
        WHERE
          tran.recordtype = 'cashsale'
        GROUP BY
          itemtype,
          order_num
      )
    GROUP BY
      order_num
  )
SELECT DISTINCT
  tran.custbody_goodr_shopify_order order_num,
  channel.name,
  product_sales,
  tran.recordtype,
  ship_rate,
  tran.estgrossprofit AS gross_profit,
  tran.estgrossprofitpercent AS profit_percent
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN ns_salesrev ON ns_salesrev.order_num = tran.custbody_goodr_shopify_order
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
WHERE
  order_num = 'G1348972'