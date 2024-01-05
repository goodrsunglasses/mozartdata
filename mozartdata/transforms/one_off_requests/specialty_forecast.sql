with
 customer as
(
select
  c.email as email
, c.customer_id_edw

from
  dim.customer c
inner join
  fact.customer_shopify_map csm
  on c.customer_id_edw = csm.customer_id_edw

where
  c.customer_category = 'B2B'
  and prospect_flag = 0
)
, grid as
(
  select 
    * 
  from
    (select distinct yrq, yrmo, month from dim.date where yrmo >= 202201) a
  cross join
  (select distinct email, customer_id_edw from customer) b
)
, ltv as 
(
select 
  c.email
, o.channel
,  DATEDIFF(DAY, fc.first_order_date, '2023-12-31') date_diff
, sum(coalesce(o.amount_sold,0)) ltv 
, case 
  when DATEDIFF(DAY, fc.first_order_date, '2023-12-31') >=0 and DATEDIFF(DAY, fc.first_order_date, '2023-12-31') <= 90 then 'Tier 4'
  when sum(coalesce(o.amount_sold,0))  > 100000 then 'Tier 1'
  when sum(coalesce(o.amount_sold,0)) > 50000 then 'Tier 2'
  when sum(coalesce(o.amount_sold,0))  > 300 then 'Tier 3'
  else 'Other'
  end as tier
, fc.most_recent_order_date last_order_date
, fc.first_order_date created_date
from 
  fact.orders o
inner join
  customer c
  on c.customer_id_edw = o.customer_id_edw
left join
  fact.customer fc
  on c.customer_id_edw = fc.customer_id_edw
group by
  c.email
, o.channel
, fc.most_recent_order_date
, fc.first_order_date
order by 
  tier asc
)
, revenue as
(
  select
    c.email
  , mc.yrmo
  , mc.yrq
  , sum(coalesce(o.amount_sold,0)) revenue
  , count(o.order_id_edw) order_count
  from 
    fact.orders o
  inner join
  customer c
  on c.customer_id_edw = o.customer_id_edw
  inner join
    dim.date mc
    on mc.date = o.sold_date
  group by
    c.email
  , mc.yrmo
  , mc.yrq
)
  select 
    g.email
  , ltv.created_date
  , g.yrmo
  , g.yrq
  , g.month
  , ltv.last_order_date
  , DATEDIFF(DAY, ltv.last_order_date, GETDATE()) days_since_last_order
  , ltv.tier
  , ltv.ltv
  , coalesce(r.revenue,0) revenue
  , coalesce(r.order_count,0) order_count
  from 
    grid g
  inner join
    ltv
    on g.email = ltv.email
  left join
    revenue r
    on g.email = r.email
    and g.yrmo = r.yrmo
  where tier = 'Tier 1' --Change tier here
  order by email asc, yrmo asc