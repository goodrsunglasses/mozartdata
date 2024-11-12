with ns_orders as
  (
    select
      o.customer_id_edw
    , max(cnm.email) over (partition by o.customer_id_edw ) as email
    , max(cnm.normalized_phone_number)  over (partition by o.customer_id_edw ) as phone_number
    , o.sold_date
    , c.customer_category
    , o.order_id_edw
    , row_number() over (partition by o.customer_id_edw order by o.sold_date) as lifetime_rn
    , row_number() over (partition by o.customer_id_edw, c.customer_category order by o.sold_date) as channel_rn
    , sum(o.amount_revenue_sold) over (partition by o.customer_id_edw) as lifetime_revenue
    , sum(o.amount_revenue_sold) over (partition by o.customer_id_edw, c.customer_category) as channel_revenue
    from
      fact.orders o
    left join
      dim.channel c
      on o.channel = c.name
    left join
      fact.customer_ns_map cnm
      on o.customer_id_ns = cnm.customer_id_ns
    where o.customer_id_edw = '000085938da23c60553cee0873d56a9a'
  )
   , shopify_orders as
  (
    select
      o.customer_id_shopify
    , csm.customer_id_edw
    , max(csm.email)  over (partition by csm.customer_id_edw ) as email
    , max(csm.normalized_phone_number)  over (partition by csm.customer_id_edw) as phone_number
    , o.sold_date
    , c.customer_category
    , o.order_id_edw
    , row_number() over (partition by csm.customer_id_edw order by o.sold_date) lifetime_rn
    , row_number() over (partition by csm.customer_id_edw, c.customer_category order by o.sold_date) store_rn
    , sum(o.amount_revenue_sold) over (partition by csm.customer_id_edw) as lifetime_revenue
    , sum(o.amount_revenue_sold) over (partition by csm.customer_id_edw, c.customer_category) as store_revenue
    from
      fact.shopify_orders o
    left join
      fact.customer_shopify_map csm
      on csm.id = o.customer_id_shopify
    left join
      dim.channel c
      on o.store = case when c.name = 'goodr.ca' then 'Goodr.ca' else c.name end
  )
, final as
       (
         SELECT
           n.customer_id_edw
         , n.customer_category
         , n.email
         , n.phone_number
         , MAX(CASE WHEN n.channel_rn = 1 THEN n.sold_date ELSE NULL END) AS first_order_date_ns
         , MAX(CASE WHEN n.channel_rn = 2 THEN n.sold_date ELSE NULL END) AS second_order_date_ns
         , CASE WHEN MAX(n.channel_rn) = 1 THEN TRUE ELSE FALSE END       AS new_customer_flag_ns
         , MAX(n.channel_rn)                                              AS order_count
         , n.channel_revenue
         FROM
           ns_orders n
         GROUP BY ALL
         UNION ALL
         SELECT
           s.customer_id_edw
         , s.customer_category
         , s.email
         , s.phone_number
         , MAX(CASE WHEN s.store_rn = 1 THEN s.sold_date ELSE NULL END) AS first_order_date_ns
         , MAX(CASE WHEN s.store_rn = 2 THEN s.sold_date ELSE NULL END) AS second_order_date_ns
         , CASE WHEN MAX(s.store_rn) = 1 THEN TRUE ELSE FALSE END       AS new_customer_flag_ns
         , MAX(s.store_rn)                                              AS order_count
         , s.store_revenue
         FROM
           shopify_orders s
         GROUP BY ALL
         )
select
  *
from
  final f
order by customer_id_edw limit 1000