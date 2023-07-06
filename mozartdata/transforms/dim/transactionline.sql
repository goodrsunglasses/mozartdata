SELECT
  transaction,
  item,
  items.displayname,
  --- sku number? for easier filtering later
  averagecost,
  quantity,
  rate,
  tran.ns_trandate,
  tran.ns_channel
  
FROM
netsuite.transactionline tranline

  LEFT JOIN netsuite.item items on tranline.item = items.id
  LEFT JOIN dim.transactions tran on tran.ns_id = tranline.transaction