SELECT
  tran.tranid,
  tran.createddate,
  item.displayname,
  tranline.quantity,
  loc.fullname
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN netsuite.location loc ON loc.id = tranline.location
  left outer join netsuite.item item on item.id = tranline.item
WHERE
  tran.createddate >= '2023-01-01T00:00:00Z'
  AND loc.fullname LIKE '%DO NOT USE%'
  and tranline.itemtype = 'InvtPart'
ORDER BY
  createddate desc