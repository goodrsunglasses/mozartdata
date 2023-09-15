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
      FIRST_VALUE(tran.memo) OVER (
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
      ) AS memo,
      --Grabs the first value from the transaction type ranking, this time ignoring invoices, with a secondary sort that is going for oldest createddate first 
      FIRST_VALUE(tran.createddate) OVER (
        PARTITION BY
          order_num
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'salesorder' THEN 2
            ELSE 3
          END,
          tran.createddate ASC
      ) AS oldest_createddate,
      -- Uses Coalesce logic to give us the Sum of all the cashsale record's estgrossprift, provided there are none then we take the invoices sum of estgrossprofit
      SUM(
        CASE
          WHEN tran.recordtype IN ('invoice', 'cashsale') THEN tran.estgrossprofit
        END
      ) OVER (
        PARTITION BY
          order_num
      ) AS prioritized_grossprofit_sum,
      AVG(
        CASE
          WHEN tran.recordtype IN ('invoice', 'cashsale') THEN tran.estgrossprofitpercent
        END
      ) OVER (
        PARTITION BY
          order_num
      ) AS prioritized_estgrossprofitpercent_avg,
      SUM(
        CASE
          WHEN tran.recordtype IN ('invoice', 'cashsale') THEN tran.totalcostestimate
        END
      ) OVER (
        PARTITION BY
          order_num
      ) AS prioritized_totalcostestimate_sum,
      FIRST_VALUE(
        CASE
          WHEN transtatus.fullname LIKE ANY(
            '%Closed',
            '%Voided',
            '%Undefined',
            '%Rejected',
            '%Unapproved',
            '%Not Deposited'
          ) THEN TRUE
          ELSE FALSE
        END
      ) OVER (
        ORDER BY
          CASE
            WHEN transtatus.fullname LIKE ANY(
              '%Closed',
              '%Voided',
              '%Undefined',
              '%Rejected',
              '%Unapproved',
              '%Not Deposited'
            ) THEN 1
            ELSE 2
          END
      ) AS status_flag_edw
    FROM
      netsuite.transaction tran
      LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
        tran.status = transtatus.id
        AND tran.type = transtatus.trantype
      )
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
          WHEN tranline_ns.itemtype = 'NonInvtPart'
          AND tranline_ns.custcol2 LIKE '%GC-%' THEN -1 * quantity
          ELSE 0
        END
      ) AS quantity_sold,
      SUM(
        CASE
          WHEN tranline_ns.itemtype IN ('Assembly', 'InvtPart') THEN rate * (- quantity)
          WHEN tranline_ns.itemtype = 'NonInvtPart'
          AND tranline_ns.custcol2 LIKE '%GC-%' THEN rate * (- quantity)
          ELSE 0
        END
      ) AS product_rate,
      SUM(
        CASE
          WHEN tranline_ns.itemtype IN ('Assembly', 'InvtPart') THEN -1 * netamount
          WHEN tranline_ns.itemtype = 'NonInvtPart'
          AND tranline_ns.custcol2 LIKE '%GC-%' THEN -1 * netamount
          ELSE 0
        END
      ) AS total_product_amount,
      SUM(
        CASE
          WHEN tranline_ns.itemtype = 'ShipItem' THEN rate
          ELSE 0
        END
      ) AS ship_rate,
      SUM(
        CASE
          WHEN tranline_ns.itemtype = 'TaxItem' THEN - netamount
          ELSE 0
        END
      ) AS rate_tax,
      SUM(
        CASE
          WHEN tranline_ns.linesequencenumber = 0 THEN netamount
        END
      ) AS amount_total
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
          WHEN tranline_ns.itemtype = 'InvtPart' THEN -1 * tranline_ns.quantity
          WHEN tranline_ns.itemtype = 'Assembly' THEN itemmember.quantity * - (tranline_ns.quantity)
          ELSE 0
        END
      ) AS quantity_fulfilled
    FROM
      netsuite.transactionline tranline_ns
      INNER JOIN netsuite.transaction tran_ns ON tran_ns.id = tranline_ns.transaction
      LEFT OUTER JOIN netsuite.item item ON item.id = tranline_ns.item
      LEFT OUTER JOIN netsuite.itemmember itemmember ON item.id = itemMember.parentitem
    WHERE
      tran_ns.recordtype = 'itemfulfillment'
    GROUP BY
      order_num
  ),
  line_info_refunded AS (
    SELECT DISTINCT
      tran_ns.custbody_goodr_shopify_order order_num,
      FIRST_VALUE(tran_ns.createddate) OVER (
        PARTITION BY
          order_num
        ORDER BY
          tran_ns.createddate ASC
      ) AS oldest_createddate_refund,
      SUM(
        CASE
          WHEN tranline_ns.itemtype IN ('Assembly', 'InvtPart', 'OthCharge') THEN netamount
          WHEN tranline_ns.itemtype = 'NonInvtPart'
          AND tranline_ns.custcol2 LIKE '%GC-%' THEN -1 * netamount
          ELSE 0
        END
      ) OVER (
        PARTITION BY
          order_num
      ) AS total_product_amount_refunded,
      SUM(
        CASE
          WHEN tranline_ns.itemtype IN ('ShipItem', 'Payment') THEN rate
          ELSE 0
        END
      ) OVER (
        PARTITION BY
          order_num
      ) AS amount_refunded_shipping,
      SUM(
        CASE
          WHEN tranline_ns.itemtype = 'TaxItem' THEN netamount
          ELSE 0
        END
      ) OVER (
        PARTITION BY
          order_num
      ) AS amount_refunded_tax,
      SUM(
        CASE
          WHEN tranline_ns.linesequencenumber = 0 THEN - netamount
        END
      ) OVER (
        PARTITION BY
          order_num
      ) AS amount_refunded_total
    FROM
      netsuite.transactionline tranline_ns
      INNER JOIN netsuite.transaction tran_ns ON tran_ns.id = tranline_ns.transaction
    WHERE
      tran_ns.recordtype = 'cashrefund'
  )
SELECT DISTINCT
  order_numbers.order_num AS order_id_edw,
  CONVERT_TIMEZONE('America/Los_Angeles', oldest_createddate) AS timestamp_transaction_PST,
  channel.name AS channel,
  CASE
    WHEN memo LIKE '%RMA%' THEN TRUE
    ELSE FALSE
  END AS is_exchange,
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
  CASE
    WHEN channel IN (
      'Specialty',
      'Key Account',
      'Key Account CAN',
      'Specialty CAN'
    ) THEN 'Wholesale'
    WHEN channel IN ('Goodr.com', 'Goodr.com CAN') THEN 'Website'
    WHEN channel IN ('Amazon', 'Prescription') THEN 'Partners'
    WHEN channel IN ('Cabana') THEN 'Retail'
    WHEN channel IN ('Global') THEN 'Distribution'
  END AS model,
  prioritized_cust_id AS customer_id_ns,
  quantity_sold,
  quantity_fulfilled,
  prioritized_grossprofit_sum AS profit_gross,
  -- prioritized_estgrossprofitpercent_avg AS profit_percent,
  prioritized_totalcostestimate_sum AS cost_estimate,
  CASE
    WHEN channel = 'Cabana' THEN total_product_amount
    ELSE product_rate
  END AS rate_items, --works for right now, will change given 
  total_product_amount AS amount_items,
  ship_rate AS amount_ship,
  rate_tax AS amount_tax,
  amount_total,
  CASE
    WHEN total_product_amount_refunded IS NOT NULL THEN TRUE
    ELSE FALSE
  END AS has_refund,
  CONVERT_TIMEZONE('America/Los_Angeles', oldest_createddate_refund) AS timestamp_refund_PST,
  total_product_amount_refunded AS amount_refunded_items,
  amount_refunded_shipping,
  amount_refunded_tax,
  amount_refunded_total,
  CASE
    WHEN status_flag_edw THEN TRUE
    ELSE FALSE
  END AS status_flag_edw
FROM
  order_numbers
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON order_numbers.prioritized_channel_id = channel.id
  LEFT OUTER JOIN line_info_sold ON line_info_sold.order_num = order_numbers.order_num
  LEFT OUTER JOIN line_info_fulfilled ON line_info_fulfilled.order_num = order_numbers.order_num
  LEFT OUTER JOIN line_info_refunded ON line_info_refunded.order_num = order_numbers.order_num