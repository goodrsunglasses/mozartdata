WITH
  nestsales AS (
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
  ),
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
      tran.entity AS customer_id,
      tran.trandate,
      tran.shippingaddress AS shippingaddress_id,
      location.name AS location
    FROM
      nestsales
      LEFT OUTER JOIN netsuite.transaction tran ON tran.id = nestsales.id
      LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
      LEFT OUTER JOIN netsuite.location location ON location.id = nestsales.location
  ),
  ns_cashrefund AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid as ns_rf_id
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'cashrefund'
  ),
  ns_itemfulfillment AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid as ns_if_id
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'itemfulfillment'
  )
  ,
  ns_cashsale AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid as ns_cs_id
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'cashsale'
  )
SELECT
  ns_salesorder.order_num as order_id,
  channel,
  products_rate as rate_items,
  products_amount as amount_items,
  ship_rate as rate_ship,
  total_quantity as quantity_items,
  gross_profit as profit_gross,
  profit_percent as profit_percent,
  totalcostestimate as cost_estimate,
  startDate as date_ship_window_start,
  enddate as date_ship_window_end,
  customer_id as cust_id,
  trandate as date_tran, 
  shippingaddress_id as address_ship_id,
  location,
  ns_rf_id,
  ns_if_id,
  ns_cs_id
  
FROM
  ns_salesorder
  LEFT OUTER JOIN ns_cashrefund ON ns_cashrefund.order_num = ns_salesorder.order_num
  LEFT OUTER JOIN ns_itemfulfillment ON ns_itemfulfillment.order_num = ns_salesorder.order_num
  LEFT OUTER JOIN ns_cashsale ON ns_cashsale.order_num = ns_salesorder.order_num