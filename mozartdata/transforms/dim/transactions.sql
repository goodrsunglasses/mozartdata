SELECT 
  transaction.tranid as NS_transaction_ID,
  transaction.recordtype as ns_transacation_type,
  transaction.entity as ns_cust_id,
  transaction.id as NS_ID,
  transaction.trandate as ns_transaction_date,
  -- shopifyid
  -- shopifycustid
  -- shopifytranid
  channel.name as ns_channel
  
FROM netsuite.transaction transaction
left outer join netsuite.customrecord_cseg7 channel on transaction.cseg7=channel.id