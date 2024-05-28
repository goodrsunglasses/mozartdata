with orders as
       (select distinct o.ORDER_ID_EDW
                      , o.CHANNEL
        from fact.order_item oi
               inner join
             fact.orders o
             on oi.order_id_edw = o.order_id_edw
        where o.channel = 'Marketing'
          and location = 'HQ DC'
          and oi.plain_name = 'Discount'
          and oi.ITEM_ID_NS = 7322 --Discount - PR (discount for Starbucks)
       )
select
  o.*
, gt.TRANSACTION_ID_NS
, gt.TRANSACTION_NUMBER_NS
, gt.ACCOUNT_NUMBER
, gt.NET_AMOUNT
from
  orders o
left join
  fact.GL_TRANSACTION gt
  on gt.ORDER_ID_EDW = o.ORDER_ID_EDW
where
  (gt.ACCOUNT_NUMBER is not null or (account_number is null and gt.NET_AMOUNT != 0))
order by
  o.ORDER_ID_EDW
, gt.TRANSACTION_NUMBER_NS
, gt.ACCOUNT_NUMBER