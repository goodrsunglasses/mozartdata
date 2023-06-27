SELECT 
  transaction.tranid,
  transaction.entity,
  transaction.id,
  -- transaction.companyid,
  -- shopifyid
  -- shopifycustid
  -- shopifytranid
  channel.name
  
FROM netsuite.transaction transaction
left outer join netsuite.customrecord_cseg7 channel on transaction.cseg7=channel.id