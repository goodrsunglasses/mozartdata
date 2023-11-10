SELECT 
  c.companyname distributor
, c.entityid customer_id
-- , c.email
, o.order_date_pst order_date
, o.order_id_edw
, o.quantity_booked
, o.quantity_sold
, o.quantity_fulfilled
, o.quantity_refunded
, o.amount_booked
, o.amount_sold
, o.amount_refunded
from 
  fact.orders o
inner join
  fact.customer_ns_map cnm
  on cnm.customer_id_edw = o.customer_id_edw
inner join
  netsuite.customer c
  on cnm.customer_internal_id_ns = c.id
where 
  o.model = 'Distribution'
  and o.order_date_pst >= '2023-01-01'
order by distributor, order_date_pst