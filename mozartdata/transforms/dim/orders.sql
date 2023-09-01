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
  --CTE to select all the unique order numbers from all transaction records of the salesorder and cashsale type
  order_numbers AS (
    SELECT DISTINCT
      tran.custbody_goodr_shopify_order order_num,
      FIRST_VALUE(tran.cseg7) OVER (
        PARTITION BY
          order_num
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'invoice' THEN 2
            WHEN tran.recordtype = 'salesorder' THEN 3
            ELSE 4
          END
      ) AS prioritized_channel_id,
      tran.estgrossprofit AS gross_profit,
      tran.estgrossprofitpercent AS profit_percent,
      tran.totalcostestimate,
      tran.entity AS customer_id
    FROM
      netsuite.transaction tran
  -- LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
  --       tran.status = transtatus.id
  --       AND tran.type = transtatus.trantype
  --     )
    WHERE
      tran.recordtype IN ('cashsale', 'invoice', 'salesorder')
  ),
  --CTE that calculates the respective product rates, total product amounts, total quantity and shipping rate based on the line item type, it grabs from the Cashsale and invoice records as they are presumed to be the sources of truth
  line_info_sold AS (
    SELECT
      tran_ns.custbody_goodr_shopify_order order_num,
      SUM(
        CASE
          WHEN tranline_ns.itemtype = 'InvtPart' THEN -1 * quantity
          ELSE 0
        END
      ) AS quantity_sold,
      SUM(
        CASE
          WHEN tranline_ns.itemtype = 'InvtPart' THEN rate
          ELSE 0
        END
      ) AS product_rate,
      SUM(
        CASE
          WHEN tranline_ns.itemtype = 'InvtPart' THEN -1 * netamount
          ELSE 0
        END
      ) AS total_product_amount,
      SUM(
        CASE
          WHEN tranline_ns.itemtype = 'ShipItem' THEN rate
          ELSE 0
        END
      ) AS ship_rate
    FROM
      netsuite.transactionline tranline_ns
      INNER JOIN netsuite.transaction tran_ns ON tran_ns.id = tranline_ns.transaction
    WHERE
      tran_ns.recordtype IN ('cashsale', 'invoice')
    GROUP BY
      order_num
  ),
  line_info_fulfilled AS (
    SELECT
      tran_ns.custbody_goodr_shopify_order order_num,
      SUM(
        CASE
          WHEN tranline_ns.itemtype = 'InvtPart' THEN -1 * quantity
          ELSE 0
        END
      ) AS quantity_fulfilled
    FROM
      netsuite.transactionline tranline_ns
      INNER JOIN netsuite.transaction tran_ns ON tran_ns.id = tranline_ns.transaction
    WHERE
      tran_ns.recordtype = 'itemfulfillment'
    GROUP BY
      order_num
  )
SELECT DISTINCT
  order_numbers.order_num as order_id_edw,
  channel.name AS channel,
  CASE
    WHEN channel IN ('Specialty', 'Key Account', 'Global') THEN 'B2B'
    WHEN channel IN ('Goodr.com', 'Amazon', 'Cabana','Customer Service') THEN 'D2C'
  END AS b2b_d2c, --- d2c or b2b as categorized by sales, which is slightly different than for ops
  customer_id as cust_id_ns,
  quantity_sold,
  quantity_fulfilled,
  gross_profit as profit_gross,
  profit_percent,
  totalcostestimate as cost_estimate,
  product_rate as rate_items,
  total_product_amount as amount_items,
  ship_rate as rate_ship
FROM
  order_numbers
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON order_numbers.prioritized_channel_id = channel.id
  LEFT OUTER JOIN line_info_sold ON line_info_sold.order_num = order_numbers.order_num
  LEFT OUTER JOIN line_info_fulfilled ON line_info_fulfilled.order_num = order_numbers.order_num