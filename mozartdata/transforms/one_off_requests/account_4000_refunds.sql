SELECT
  gt.order_id_ns
, gt.transaction_id_ns
, gt.transaction_date
, tran.recordtype
, gt.net_amount
FROM
  fact.gl_transaction gt
inner JOIN
  netsuite.transaction tran
  on tran.id = gt.transaction_id_ns
WHERE
  gt.account_number = 4000
and tran.recordtype = 'cashrefund'