-- purpose:
-- One row per transaction.
-- This transform creates the transactions dimension by combining data from netsuite and shopify.
-- aliases: 
-- ns = netsuite
-- shop = shopify
-- cust = customer
SELECT
  transaction.tranid AS NS_transaction_ID, --netsuite transaction id
  transaction.trandate AS ns_trandate,--netsuite transaction date
  transaction.recordtype AS ns_transaction_type,
  transaction.entity AS ns_cust_id,
  transaction.id AS NS_ID,
  shopord.id AS shopify_id,
  shopord.name AS shopify_tran_id,
  channel.name AS ns_channel,
  transtatus.fullname AS ns_transaction_status,
  billaddress.state AS ns_billing_state,
  shipaddress.state AS ns_shipping_state
FROM
  netsuite.transaction transaction
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON transaction.cseg7 = channel.id
  LEFT OUTER JOIN shopify."ORDER" shopord ON shopord.name = transaction.custbody_goodr_shopify_order
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    transaction.status = transtatus.id
    AND transaction.type = transtatus.trantype
  )
  LEFT OUTER JOIN netsuite.transactionBillingAddress billaddress ON billaddress.nkey = transaction.billingaddress
  LEFT OUTER JOIN netsuite.transactionShippingAddress shipaddress ON shipaddress.nkey = transaction.shippingaddress
WHERE
  ns_transaction_id IS NOT NULL -- Filtering out all the seemingly null transactions we have
  AND ns_transaction_type NOT IN (
    'binworksheet',
    'bintransfer',
    'assemblyunbuild',
    'assemblybuild'
  ) --filter out uneeded transaction types
ORDER BY
  ns_transaction_id desc