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
      --Grabs the first value from the transaction type ranking, with a secondary sort that is going for oldest createddate first 
      FIRST_VALUE(tran.cseg7) OVER (
        PARTITION BY
          order_num
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'invoice' THEN 2
            WHEN tran.recordtype = 'salesorder' THEN 3
            ELSE 4
          END,
          tran.createddate ASC
      ) AS prioritized_channel_id,
      FIRST_VALUE(tran.entity) OVER (
        PARTITION BY
          order_num
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'invoice' THEN 2
            WHEN tran.recordtype = 'salesorder' THEN 3
            ELSE 4
          END,
          tran.createddate ASC
      ) AS prioritized_cust_id,
      --Grabs the first value from the transaction type ranking, this time ignoring invoices, with a secondary sort that is going for oldest createddate first 
      FIRST_VALUE(tran.createddate) OVER (
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'salesorder' THEN 2
            ELSE 3
          END,
          tran.createddate ASC
      ) AS oldest_createddate,
      -- Uses Coalesce logic to give us the Sum of all the cashsale record's estgrossprift, provided there are none then we take the invoices sum of estgrossprofit
      COALESCE(
        SUM(
          CASE
            WHEN tran.recordtype = 'cashsale' THEN tran.estgrossprofit
          END
        ) OVER ( PARTITION BY
          order_num),
        SUM(
          CASE
            WHEN tran.recordtype = 'invoice' THEN tran.estgrossprofit
          END
        ) OVER ( PARTITION BY
          order_num)
      ) AS prioritized_grossprofit_sum,
      COALESCE(
        AVG(
          CASE
            WHEN tran.recordtype = 'cashsale' THEN tran.estgrossprofitpercent
          END
        ) OVER ( PARTITION BY
          order_num),
        AVG(
          CASE
            WHEN tran.recordtype = 'invoice' THEN tran.estgrossprofitpercent
          END
        ) OVER ( PARTITION BY
          order_num)
      ) AS prioritized_estgrossprofitpercent_avg,
      COALESCE(
        SUM(
          CASE
            WHEN tran.recordtype = 'cashsale' THEN tran.totalcostestimate
          END
        ) OVER ( PARTITION BY
          order_num),
        SUM(
          CASE
            WHEN tran.recordtype = 'invoice' THEN tran.totalcostestimate
          END
        ) OVER ( PARTITION BY
          order_num)
      ) AS prioritized_totalcostestimate_sum
    FROM
      netsuite.transaction tran
      -- LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
      --       tran.status = transtatus.id
      --       AND tran.type = transtatus.trantype
      --     ) commented out until we know what we wanna do transaction status wise
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
          WHEN tranline_ns.itemtype = 'InvtPart' THEN rate * (- quantity)
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
  order_numbers.order_num AS order_id_edw,
  CONVERT_TIMEZONE('America/Los_Angeles', oldest_createddate) AS timestamp_transaction_PST,
  channel.name AS channel,
  CASE
    WHEN channel IN (
      'Specialty',
      'Key Account',
      'Global',
      'Key Account CAN',
      'Specialty CAN'
    ) THEN 'B2B'
    WHEN channel IN (
      'Goodr.com',
      'Amazon',
      'Cabana',
      'Goodr.com CAN',
      'Prescription'
    ) THEN 'D2C'
    WHEN channel IN (
      'Goodrwill.com',
      'Customer Service CAN',
      'Marketing',
      'Customer Service'
    ) THEN 'INDIRECT'
  END AS b2b_d2c, --- d2c or b2b as categorized by sales, which is slightly different than for ops
  prioritized_cust_id AS customer_id_ns,
  quantity_sold,
  quantity_fulfilled,
  prioritized_grossprofit_sum AS profit_gross,
  prioritized_estgrossprofitpercent_avg as profit_percent,
  prioritized_totalcostestimate_sum AS cost_estimate,
  product_rate AS rate_items,
  total_product_amount AS amount_items,
  ship_rate AS rate_ship
FROM
  order_numbers
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON order_numbers.prioritized_channel_id = channel.id
  LEFT OUTER JOIN line_info_sold ON line_info_sold.order_num = order_numbers.order_num
  LEFT OUTER JOIN line_info_fulfilled ON line_info_fulfilled.order_num = order_numbers.order_num
where order_id_edw='SG-72004'