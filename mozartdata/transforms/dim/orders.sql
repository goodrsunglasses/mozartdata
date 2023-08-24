/*
THIS TRANSFORM IS IN DRAFT, DO NOT JOIN TO THIS TRANSFORM OR USE IT FOR ANY REPORTING UNTIL IT IS CERTIFIED.
purpose:
One row per sales order.
This transform creates an order dimension that combines shopify, netsuite and RF Smart information together to give a full picture of the order.

joins: 
Sales Order CTE to Cash Sale, Cash Refund, and Item Fulfillment CTEs on order_num which is shopify's order number that is pulled into NS using custbody_goodr_shopify_order and is being pulled from NS.

aliases: 
ns = netsuite
shop = shopify
cust = customer
custbody_goodr_shopify_order = order_num (this is the shopify order number, and is pulled into NS using the custom field custbody_goodr_shopify_order)

*/
WITH
  --CTE that calculates the respective product rates, total product amounts, total quantity and shipping rate based on the line item type. Additionally for joining purposes it grabs the transaction id, Goodr Order Number and the location id.
  transactionline_ns AS (
    SELECT
      tran_ns.id,
      tran_ns.custbody_goodr_shopify_order order_num,
      tranline_ns.location,
      --Aggregrate that selects the product rate when the line item is of type InvtPart, summing all those rates
      CASE
        WHEN tranline_ns.itemtype = 'InvtPart' THEN (SUM(rate))
        ELSE NULL
      END AS product_rate,
      --Aggregrate that selects the total product amount when the line item is of type InvtPart, summing all those netamounts, to get the amount after discounts and such
      CASE
        WHEN tranline_ns.itemtype = 'InvtPart' THEN -1 * (SUM(netamount))
        ELSE NULL
      END AS total_product_amount,
      --Aggregrate that selects the quantity when the line item is of type InvtPart, summing it to get the total quantity
      CASE
        WHEN tranline_ns.itemtype = 'InvtPart' THEN -1 * (SUM(quantity))
        ELSE NULL
      END AS total_quantity,
      --Aggregrate that selects the rate when the line item is of type ShipItem, grabbing the MAX of that collumn to avoid any null or repeating ones
      CASE
        WHEN tranline_ns.itemtype = 'ShipItem' THEN MAX(rate)
        ELSE NULL
      END AS ship_rate
    FROM
      netsuite.transactionline tranline_ns
      LEFT OUTER JOIN netsuite.transaction tran_ns ON tran_ns.id = tranline_ns.transaction
    WHERE
      tran_ns.recordtype = 'salesorder'
    GROUP BY
      itemtype,
      tran_ns.id,
      order_num,
      location
  ),
  --CTE That grabs the bulk of the information to make up an 'order', as the parent record for every order barring extraneous circumstances should be an SO, the window functions are to avoid having to add on dozens of fields to the group by clause
  salesorder_ns AS (
    SELECT DISTINCT
      order_num,
      channel.name AS channel,
      transtatus.fullname AS tran_status,
      --window function that grabs the max of the product rate sum from transactionline_ns, as it and all the other aggregates are stored on a variable number of rows
      MAX(product_rate) OVER (
        PARTITION BY
          order_num
      ) AS products_rate,
      --window function that grabs the max of the total_product_amount sum from transactionline_ns, as it and all the other aggregates are stored on a variable number of rows
      MAX(total_product_amount) OVER (
        PARTITION BY
          order_num
      ) AS products_amount,
      --window function that grabs the max of the ship_rate sum from transactionline_ns, as it and all the other aggregates are stored on a variable number of rows
      MAX(ship_rate) OVER (
        PARTITION BY
          order_num
      ) AS ship_rate,
      --window function that grabs the max of the total_quantity sum from transactionline_ns, as it and all the other aggregates are stored on a variable number of rows
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
      transactionline_ns
      LEFT OUTER JOIN netsuite.transaction tran ON tran.id = transactionline_ns.id
      LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
      LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
        tran.status = transtatus.id
        AND tran.type = transtatus.trantype
      )
    WHERE  --- ***KSL IS THIS FILTERING OUT CLOSED ORDERS FROM THIS TABLE???
      tran_status NOT LIKE '%Closed%'
      AND location_id IS NOT NULL
  ),
  --CTE that grabs the perspective related cash refund to the greater order
  cashrefund_ns AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid AS cr_id_ns
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'cashrefund'
  ),
  --CTE that grabs the perspective related item fulfillment to the greater order
  itemfulfillment_ns AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid AS if_id_ns
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'itemfulfillment'
  ),
  --CTE that grabs the perspective related cash sale to the greater order
  cashsale_ns AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid AS cs_id_ns
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'cashsale'
  )
SELECT
  salesorder_ns.order_num AS order_id_ns,
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
  END AS b2b_d2c, --- d2c or b2b as categorized by sales, which is slightly different than for ops
  cr_id_ns, --- netsuite cash refund id
  if_id_ns, --- netsuite item fulfillment id
  cs_id_ns --- netsuite cash sale id
FROM
  salesorder_ns
  LEFT OUTER JOIN cashrefund_ns ON cashrefund_ns.order_num = salesorder_ns.order_num
  LEFT OUTER JOIN itemfulfillment_ns ON itemfulfillment_ns.order_num = salesorder_ns.order_num
  LEFT OUTER JOIN cashsale_ns ON cashsale_ns.order_num = salesorder_ns.order_num