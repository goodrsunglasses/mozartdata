select
p.sku
,sum(o.amount_sold)
from
fact.orders o
inner join
fact.order_item oi
on o.order_id_edw = oi.order_id_edw
inner join
draft_dim.product p
on p.item_id_ns = oi.item_id_ns
group by
p.sku