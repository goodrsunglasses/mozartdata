SELECT
  tranid,
  createddate,
  transferlocation
FROM
  netsuite.transaction
WHERE
  recordtype = 'transferorder'