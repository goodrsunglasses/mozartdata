select
  gt.POSTING_PERIOD
, cust.entityid
, cust.COMPANYNAME
, sum(gt.NET_AMOUNT) net_amount
from
  fact.gl_transaction gt
inner join
  NETSUITE.TRANSACTION tran
  on gt.TRANSACTION_ID_NS = tran.id
LEFT OUTER JOIN
    netsuite.customer cust
    ON cust.id = tran.entity
where
  gt.CHANNEL = 'Key Account'
  and gt.ACCOUNT_NUMBER between '4000' and '4999'
  and gt.POSTING_FLAG
  and to_date(gt.POSTING_PERIOD, 'MON YYYY') >= '2022-01-01'
group by
    gt.POSTING_PERIOD
 , cust.entityid
, cust.COMPANYNAME
order by
  to_date(gt.POSTING_PERIOD, 'MON YYYY')
, cust.entityid