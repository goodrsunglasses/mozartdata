with order_dates as
  (
  select distinct
  order_id_edw
, date(first_value(transaction_event_date ignore nulls) over(PARTITION BY order_id_edw ORDER BY CASE WHEN record_type = 'salesorder' THEN 1 ELSE 2 END, transaction_event_date asc)) as order_placed_date
, date(first_value(transaction_event_date ignore nulls) over(PARTITION BY order_id_edw  ORDER BY  CASE WHEN record_type = 'invoice' THEN 1 ELSE 2 END, transaction_event_date asc)) as revenue_date
from
  fact.order_line ol
  )
SELECT 
  c.companyname distributor
, c.entityid customer_id
-- , c.email
, o.order_date_pst order_date
, od.order_placed_date
, od.revenue_date
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
  and cnm.ns_primary_id_flag = true
left join
  order_dates od
  on o.order_id_edw = od.order_id_edw
where 
  o.model = 'Distribution'
  and od.order_placed_date >= '2022-11-01'
order by distributor, order_date_pst