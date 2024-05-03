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
  gt.CHANNEL = 'Global'
  and gt.ACCOUNT_NUMBER between '4000' and '4999'
  and gt.POSTING_FLAG
  and right(gt.posting_period,4) in ('2023','2024')
group by
    gt.POSTING_PERIOD
 , cust.entityid
, cust.COMPANYNAME
order by
  to_date(gt.POSTING_PERIOD, 'MON YYYY')
, cust.entityid