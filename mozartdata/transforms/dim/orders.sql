WITH
  ns_salesorder AS (
    SELECT DISTINCT
      order_num,
      channel.name AS channel,
      MAX(product_rate) OVER (
        PARTITION BY
          order_num
      ) AS products_rate,
      MAX(total_product_amount) OVER (
        PARTITION BY
          order_num
      ) AS products_amount,
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
      tran.totalcostestimate,
      tran.startDate,
      tran.enddate,
      tran.entity as customer_id,
      tran.trandate,
      tran.shippingaddress as shippingaddress_id,
      location.name as location
    FROM
      (
        SELECT
          tran.id,
          tran.custbody_goodr_shopify_order order_num,
          tranline.location,
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
          order_num,
          location
      ) AS nestsales
      LEFT OUTER JOIN netsuite.transaction tran ON tran.id = nestsales.id
      LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
      LEFT OUTER JOIN netsuite.location location ON location.id = nestsales.location
  )
  -- ,
  -- ns_cashsale AS (
  --   SELECT
  --     order_num,
  --     MAX(product_sales) AS product_sales,
  --     MAX(ship_rate) AS ship_rate
  --   FROM
  --     (
  --       SELECT
  --         tran.custbody_goodr_shopify_order order_num,
  --       FROM
  --         netsuite.transactionline tranline
  --         LEFT OUTER JOIN netsuite.transaction tran ON tran.id = tranline.transaction
  --       WHERE
  --         tran.recordtype = 'cashsale'
  --       GROUP BY
  --         itemtype,
  --         order_num
  --     )
  --   GROUP BY
  --     order_num
  -- )
SELECT
  *
FROM
  ns_salesorder