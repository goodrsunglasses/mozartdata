/*
purpose:
One row per sales order.
This transform creates an order dimension that combines shopify, netsuite and RF Smart information together to give a full picture of the order.

joins: ns transactions 

aliases: 
ns = netsuite
shop = shopify
cust = customer
*/
WITH
  --CTE that calculates the respective product rates, total product amounts, total quantity and shipping rate based on the line item type. Additionally for joining purposes it grabs the transaction id, Goodr Order Number and the location id.
  ns_transactionline AS (
    SELECT
      ns_tran.id,
      ns_tran.custbody_goodr_shopify_order order_num,
      ns_tranline.location,
      --Aggregrate that selects the product rate when the line item is of type InvtPart, summing all those rates
      CASE
        WHEN ns_tranline.itemtype = 'InvtPart' THEN (SUM(rate))
        ELSE NULL
      END AS product_rate,
      --Aggregrate that selects the total product amount when the line item is of type InvtPart, summing all those netamounts, to get the amount after discounts and such
      CASE
        WHEN ns_tranline.itemtype = 'InvtPart' THEN -1 * (SUM(netamount))
        ELSE NULL
      END AS total_product_amount,
      --Aggregrate that selects the quantity when the line item is of type InvtPart, summing it to get the total quantity
      CASE
        WHEN ns_tranline.itemtype = 'InvtPart' THEN -1 * (SUM(quantity))
        ELSE NULL
      END AS total_quantity,
      --Aggregrate that selects the rate when the line item is of type ShipItem, grabbing the MAX of that collumn to avoid any null or repeating ones
      CASE
        WHEN ns_tranline.itemtype = 'ShipItem' THEN MAX(rate)
        ELSE NULL
      END AS ship_rate
    FROM
      netsuite.transactionline ns_tranline
      LEFT OUTER JOIN netsuite.transaction ns_tran ON ns_tran.id = ns_tranline.transaction
    WHERE
      ns_tran.recordtype = 'salesorder'
    GROUP BY
      itemtype,
      ns_tran.id,
      order_num,
      location
  ),
  --CTE That grabs the bulk of the information to make up an 'order', as the parent record for every order barring extraneous circumstances should be an SO, the window functions are to avoid having to add on dozens of fields to the group by clause
  ns_salesorder AS (
    SELECT DISTINCT
      order_num,
      channel.name AS channel,
      transtatus.fullname AS tran_status,
      --window function that grabs the max of the product rate sum from ns_transactionline, as it and all the other aggregates are stored on a variable number of rows
      MAX(product_rate) OVER (
        PARTITION BY
          order_num
      ) AS products_rate,
      --window function that grabs the max of the total_product_amount sum from ns_transactionline, as it and all the other aggregates are stored on a variable number of rows
      MAX(total_product_amount) OVER (
        PARTITION BY
          order_num
      ) AS products_amount,
      --window function that grabs the max of the ship_rate sum from ns_transactionline, as it and all the other aggregates are stored on a variable number of rows
      MAX(ship_rate) OVER (
        PARTITION BY
          order_num
      ) AS ship_rate,
      --window function that grabs the max of the total_quantity sum from ns_transactionline, as it and all the other aggregates are stored on a variable number of rows
      MAX(total_quantity) OVER (
        PARTITION BY
          order_num
      ) AS total_quantity,
      tran.actualshipdate,
      tran.estgrossprofit AS gross_profit,
      tran.estgrossprofitpercent AS profit_percent,
      tran.totalcostestimate,
      tran.startDate,
      tran.enddate,
      tran.entity AS customer_id,
      tran.trandate,
      tran.shippingaddress AS shippingaddress_id,
      location AS location_id
    FROM
      ns_transactionline
      LEFT OUTER JOIN netsuite.transaction tran ON tran.id = ns_transactionline.id
      LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
      LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
        tran.status = transtatus.id
        AND tran.type = transtatus.trantype
      )
    WHERE
      tran_status NOT LIKE '%Closed%'
      AND location_id IS NOT NULL
  ),
  --CTE that grabs the perspective related cash refund to the greater order
  ns_cashrefund AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid AS cr_id_ns
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'cashrefund'
  ),
  --CTE that grabs the perspective related item fulfillment to the greater order
  ns_itemfulfillment AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid AS if_id_ns
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'itemfulfillment'
  ),
  --CTE that grabs the perspective related cash sale to the greater order
  ns_cashsale AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid AS cs_id_ns
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'cashsale'
  )
SELECT
  ns_salesorder.order_num AS order_id_ns,
  channel,
  tran_status,
  products_rate AS rate_items,
  products_amount AS amount_items,
  ship_rate AS rate_ship,
  total_quantity AS quantity_items,
  gross_profit AS profit_gross,
  profit_percent AS profit_percent,
  totalcostestimate AS cost_estimate,
  customer_id AS cust_id_ns,
  trandate AS timestamp_tran,
  actualshipdate as timestamp_ship,
  shippingaddress_id AS address_ship_id_ns,
  location_id,
  CASE
    WHEN channel IN ('Specialty', 'Key Account', 'Global') THEN 'B2B'
    WHEN channel IN ('Goodr.com', 'Amazon', 'Cabana') THEN 'D2C'
  END AS b2b_d2c,
  cr_id_ns, --- netsuite cash refund id
  if_id_ns, --- netsuite item fulfillment id
  cs_id_ns --- netsuite cash sale id
FROM
  ns_salesorder
  LEFT OUTER JOIN ns_cashrefund ON ns_cashrefund.order_num = ns_salesorder.order_num
  LEFT OUTER JOIN ns_itemfulfillment ON ns_itemfulfillment.order_num = ns_salesorder.order_num
  LEFT OUTER JOIN ns_cashsale ON ns_cashsale.order_num = ns_salesorder.order_num