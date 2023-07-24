/*
purpose:
One row per sku per transaction.
This transform creates the transactionline dimension by combining data from netsuite and shopify.

joins: 

aliases: 
ns = netsuite
shop = shopify
tran = transaction
*/
SELECT
  tran.NS_transaction_ID,
  tran.ns_transaction_type,
  tran.ns_cust_id,
  tran.ns_channel,
  tran.ns_trandate,
  tranline.rate
  
  
FROM
  dim.transactions tran
  left outer join netsuite.transactionline tranline on tranline.transaction = tran.ns_id
LIMIT
  600;