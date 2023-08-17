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
      custbody_goodr_po_number AS po_number,
      channel.name AS channel,
      transtatus.fullname AS tran_status,
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
  tran.custbody_goodr_shipby_date as shipby_date,
      tran.actualshipdate,
      tran.startdate,
      tran.enddate,
      tran.estgrossprofit AS gross_profit,
      tran.estgrossprofitpercent AS profit_percent,
      tran.totalcostestimate,
      tran.entity AS customer_id,
      tran.trandate,
      tran.shippingaddress AS shippingaddress_id,
      location AS location_id
    FROM
      nestsales
      LEFT OUTER JOIN netsuite.transaction tran ON tran.id = nestsales.id
      LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
      LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
        tran.status = transtatus.id
        AND tran.type = transtatus.trantype
      )
    WHERE
      tran_status NOT LIKE '%Closed%'
      AND location_id IS NOT NULL
      AND channel = 'Key Account'
  ),
  ns_quote AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid AS ns_qt_id
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'estimate'
  ),
  ns_itemfulfillment AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid AS ns_if_id
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'itemfulfillment'
  ),
  ns_invoice AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.tranid AS ns_inv_id
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype = 'invoice'
  )
SELECT
  ns_salesorder.order_num AS order_id,
  po_number,
  tran_status,
  products_rate AS rate_items,
  products_amount AS amount_items,
  ship_rate AS rate_ship,
  total_quantity AS quantity_items,
  gross_profit AS profit_gross,
  profit_percent AS profit_percent,
  totalcostestimate AS cost_estimate,
  customer_id AS cust_id,
  trandate AS date_tran,
  shipby_date,
  actualshipdate,
  ns_salesorder.startdate,
  ns_salesorder.enddate,
  shippingaddress_id AS address_ship_id,
  location_id,
  ns_qt_id,
  ns_if_id,
  ns_inv_id

FROM
  ns_salesorder
  LEFT OUTER JOIN ns_quote ON ns_quote.order_num = ns_salesorder.order_num
  LEFT OUTER JOIN ns_itemfulfillment ON ns_itemfulfillment.order_num = ns_salesorder.order_num
  LEFT OUTER JOIN ns_invoice ON ns_invoice.order_num = ns_salesorder.order_num