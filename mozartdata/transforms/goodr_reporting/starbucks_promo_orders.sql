select distinct
  o.ORDER_ID_EDW
from
  fact.order_item oi
inner join
  fact.orders o
  on oi.order_id_edw = o.order_id_edw
where
  o.channel = 'Marketing'
and location = 'HQ DC'
and oi.plain_name = 'Discount'
and oi.ITEM_ID_NS = 7322 --Discount - PR (discount for Starbucks)