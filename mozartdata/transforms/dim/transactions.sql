SELECT
  transaction.tranid AS NS_transaction_ID,
  transaction.recordtype AS ns_transaction_type,
  transaction.entity AS ns_cust_id,
  transaction.id AS NS_ID,
  transaction.trandate AS ns_transaction_date,
  transactionline.rate,
  transaction.custbody4,
  -- shopifyid
  -- shopifycustid
  -- shopifytranid
  channel.name AS ns_channel
FROM
  netsuite.transaction transaction
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON transaction.cseg7 = channel.id
  LEFT OUTER JOIN netsuite.transactionline transactionline ON transaction.id = transactionline.transaction
WHERE
  custcol2 IS NOT NULL