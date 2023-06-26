SELECT
  customer.entitytitle,
  transaction.externalid, 
  transaction.trandate,
  transaction.tranid
FROM  netsuite.transaction transaction
left outer join netsuite.customer customer on customer.id=transaction.entity