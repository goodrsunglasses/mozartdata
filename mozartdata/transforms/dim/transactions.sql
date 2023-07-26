-- purpose:
-- One row per transaction.
-- This transform creates the transactions dimension by combining data from netsuite and shopify.
-- aliases: 
-- ns = netsuite
-- shop = shopify
-- cust = customer
WITH
  prodsales AS (
    SELECT
      transaction,
      -1*(SUM(netamount)) AS discsale --After discount?
      -- SUM(rate) --Before discount?
    FROM
      netsuite.transactionline
    WHERE
      itemtype = 'InvtPart'
    GROUP BY
      transaction
  ),
  shipsales AS (
    SELECT
      transaction,
      rate AS shiprate --Before discount?
    FROM
      netsuite.transactionline
    WHERE
      itemtype = 'ShipItem'
  )
  -- select 
  --   count(NS_transaction_ID) as countran
  --   from(
SELECT
  transaction.tranid AS NS_transaction_ID,
  transaction.trandate AS ns_trandate,
  transaction.recordtype AS ns_transaction_type,
  transaction.entity AS ns_cust_id,
  transaction.id AS NS_ID,
  transactionline.netamount AS revenue,
  shopord.id AS shopify_id,
  shopord.name AS shopify_tran_id,
  channel.name AS ns_channel,
  transtatus.fullname AS ns_transaction_status,
  billaddress.state AS ns_billing_state,
  shipaddress.state AS ns_shipping_state,
  discsale as product_sales,
  shiprate as shipping_income
FROM
  netsuite.transaction transaction
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON transaction.cseg7 = channel.id
  LEFT OUTER JOIN netsuite.transactionline transactionline ON transaction.id = transactionline.transaction
  LEFT OUTER JOIN shopify."ORDER" shopord ON shopord.name = transaction.custbody_goodr_shopify_order
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    transaction.status = transtatus.id
    AND transaction.type = transtatus.trantype
  )
  LEFT OUTER JOIN netsuite.transactionBillingAddress billaddress ON billaddress.nkey = transaction.billingaddress
  LEFT OUTER JOIN netsuite.transactionShippingAddress shipaddress ON shipaddress.nkey = transaction.shippingaddress
  LEFT OUTER JOIN prodsales ON prodsales.transaction = transaction.id
  LEFT OUTER JOIN shipsales ON shipsales.transaction = transaction.id
WHERE
  transactionline.linesequencenumber = 0 --as per joshas recc, use the 0th line for the netamount that ends up being the total
  -- and transactionline.accountinglinetype is null --leave it commented out until INV issue is resolved
  AND ns_transaction_id IS NOT NULL -- Filtering out all the seemingly null transactions we have
  AND ns_transaction_type IN ('salesorder', 'cashsale', 'invoice') --optional filter
ORDER BY
  ns_transaction_id desc
  -- )