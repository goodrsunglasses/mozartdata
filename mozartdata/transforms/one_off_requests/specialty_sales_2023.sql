WITH CTE_MY_DATE AS (
SELECT DATEADD(DAY, SEQ4(), '2000-01-01') AS MY_DATE
  FROM TABLE(GENERATOR(ROWCOUNT=>100000))  -- Number of days after reference date in previous line
  )
  , my_cal as
  (
  SELECT 
-- MY_DATE as date_timestamp
         date(MY_DATE) as date
--         ,to_char(MY_DATE, 'YYYYMMDD')::int as date_int
        ,to_varchar(MY_DATE, 'YYYYMM')::int as yrmo
        -- ,YEAR(MY_DATE) as year
        -- ,MONTH(MY_DATE) as month
        -- ,MONTHNAME(MY_DATE) as moonth_name
        -- ,DAY(MY_DATE) as day
        -- ,DAYOFWEEK(MY_DATE) as day_of_week
        -- ,WEEKOFYEAR(MY_DATE) as week_of_year
        -- ,DAYOFYEAR(MY_DATE) as day_of_year       
    FROM CTE_MY_DATE
  )
, customers as --29 duplicate emails
(
select
    c.entityid ns_customer_id
  , c.email ns_email
  , sc.id shopify_customer_id
  , dc.customer_id_edw
from
  netsuite.customer c
inner join
  specialty_shopify.customer sc
  on c.email = sc.email
inner join
  draft_dim.customers dc
  on lower(dc.email) = lower(c.email)
  and dc.customer_category = 'B2B'
) 
, grid as
(
  select distinct 
    yrmo, ns_customer_id
  from my_cal y, lateral (select * from customers c where 1=1 ) 
  where y.yrmo between 201901 and 202312
)
, ltv as 
(
select 
  c.ns_customer_id
, c.customer_id_edw
, sum(amount_items) ltv 
,DATEDIFF(DAY,min(o.timestamp_transaction_pst), current_date())
, case 
  when DATEDIFF(DAY,min(o.timestamp_transaction_pst), current_date()) >=0 and DATEDIFF(DAY, min(o.timestamp_transaction_pst),current_date()) <= 90 then 'Tier 4'
  when sum(amount_items) > 100000 then 'Tier 1'
  when sum(amount_items) > 50000 then 'Tier 2'
  when sum(amount_items) > 300 then 'Tier 3'
  else 'Other'
  end as tier
, max(o.timestamp_transaction_pst) last_order_date
, min(o.timestamp_transaction_pst) first_order_date
-- , min(c.created_date) created_date
from 
  fact.orders o
inner join
  customers c
  on c.customer_id_edw = o.customer_id_edw
where
  left(o.order_id_edw,4)<>'POP-'
  and DATEDIFF(month,o.timestamp_transaction_pst, current_date()) <=15
group by
  c.ns_customer_id
, c.customer_id_edw
order by 
  tier asc
) 
, revenue as
(
  select
    c.ns_customer_id
  , mc.yrmo
  , sum(o.amount_items) revenue
  , count(o.order_id_edw) order_count
  from
    fact.orders o
  inner join
    customers c
    on o.customer_id_edw = c.customer_id_edw
  inner join
    my_cal mc
    on mc.date = date(o.timestamp_transaction_pst)
  where
    left(o.order_id_edw,4)<>'POP-'
  and o.channel = 'Specialty'
  group by
    c.ns_customer_id
  , mc.yrmo
) 
  select 
    g.ns_customer_id
  , ltv.customer_id_edw
  --, ltv.created_date
  , g.yrmo
  -- , g.yrq
  -- , g.month
  --, ltv.first_order_date
  , ltv.last_order_date
  , DATEDIFF(DAY, ltv.last_order_date, GETDATE()) days_since_last_order
  , ltv.tier mozart_tier
  , coalesce(st.tier,mozart_tier) as tier
  , coalesce(r.revenue,0) revenue
  , coalesce(r.order_count,0) order_count
  , sum(coalesce(r.revenue,0)) over(partition by g.ns_customer_id,left(r.yrmo,4)) as total_year
  , ltv.ltv
  from 
    grid g
  inner join
    ltv
    on g.ns_customer_id = ltv.ns_customer_id
  left join
    revenue r
    on g.ns_customer_id = r.ns_customer_id
    and g.yrmo = r.yrmo
  left join
    google_sheets.specialty_tiers_20231013 st
    on g.ns_customer_id = trim(left(st.ns_id,POSITION(' ',st.ns_id)))
  --where g.ns_customer_id = 'CUST725797'--tier = 'Tier 1' --Change tier here
  where g.yrmo >= 202201
  order by ns_customer_id asc, yrmo asc