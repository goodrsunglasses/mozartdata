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
  transaction.tranid AS NS_transaction_ID,
  transaction.recordtype AS ns_transaction_type,
  transaction.entity AS ns_cust_id,
  transaction.id AS NS_ID,
  transaction.trandate AS ns_transaction_date,
  transactionline.rate,
  -- shopifyid
  -- shopifycustid
  -- shopifytranid
  channel.name AS ns_channel
FROM
  netsuite.transaction transaction
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON transaction.cseg7 = channel.id
  LEFT OUTER JOIN netsuite.transactionline transactionline ON transaction.id = transactionline.transaction
  -- left outer join netsuite.salesordered salesordered on salesordered.transaction = transaction.id
WHERE
  custcol2 IS NOT NULL