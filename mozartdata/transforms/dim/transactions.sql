/* 
--- CTE to create amount field
with cte_revenue as 
  SELECT 
    transactionline.transaction id
    tranasaction.id
  FROM netsuite.transaction transaction
  left outer join netsuite.transactionline transactionline on transaction.id = transactionline.id

*/
  

SELECT 
  transaction.tranid as NS_transaction_ID,
  transaction.recordtype as ns_transaction_type,
  transaction.entity as ns_cust_id,
  transaction.id as NS_ID,
  transaction.trandate as ns_transaction_date,
  salesordered.amount,
  -- shopifyid
  -- shopifycustid
  -- shopifytranid
  channel.name as ns_channel

FROM netsuite.transaction transaction
left outer join netsuite.customrecord_cseg7 channel on transaction.cseg7=channel.id
left outer join netsuite.salesordered salesordered on salesordered.transaction = transaction.id