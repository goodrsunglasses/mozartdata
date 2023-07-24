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
  tran.ns_transaction_type,
  tranline.transaction AS ns_transactionid,
  tran.ns_cust_id,
  tran.ns_channel,
  
  item AS ns_itemid,
  items.displayname AS ns_item_displayname,
  --- sku number? for easier filtering later
  averagecost AS ns_item_avg_cost,
  quantity AS ns_quantity,
  rate AS ns_ns_rate,
  tran.ns_trandate
FROM
  netsuite.transactionline tranline
  LEFT OUTER JOIN netsuite.item items ON tranline.item = items.id
  LEFT OUTER JOIN dim.transactions tran ON tran.ns_id = tranline.transaction
LIMIT
  600;