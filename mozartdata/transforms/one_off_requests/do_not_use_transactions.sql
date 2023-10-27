SELECT
  tran.tranid,
  tran.createddate,
  tranline.item,
  loc.
FROM
  netsuite.transaction tran
  left outer join netsuite.transactionline tranline on tranline.transaction = tran.id
  LEFT OUTER JOIN netsuite.location loc on loc.id=tranline.location
where tran.createddate >= '2023-01-01T00:00:00Z'
and tranline.location like '%DO NOT USE%'
order by