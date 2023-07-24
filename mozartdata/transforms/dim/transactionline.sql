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
  
  transaction as ns_transaction,
  item as ns_itemid,
  items.displayname as ns_item_displayname,
  --- sku number? for easier filtering later
  averagecost as ns_item_avg_cost,
  quantity as ns_quantity,
  rate as ns_ns_rate,
  tran.ns_trandate,
  tran.ns_channel
  
FROM
netsuite.transactionline tranline

  LEFT outer JOIN netsuite.item items on tranline.item = items.id
  LEFT outer JOIN dim.transactions tran on tran.ns_id = tranline.transaction