WITH
  ns_orders      AS
    (
      SELECT
        o.customer_id_edw
      , MAX(cnm.email) OVER (PARTITION BY o.customer_id_edw )                                        AS email
      , MAX(cnm.normalized_phone_number) OVER (PARTITION BY o.customer_id_edw )                      AS phone_number
      , o.sold_date
      , c.customer_category
      , o.order_id_edw
      , ROW_NUMBER() OVER (PARTITION BY o.customer_id_edw ORDER BY o.sold_date)                      AS lifetime_rn
      , ROW_NUMBER() OVER (PARTITION BY o.customer_id_edw, c.customer_category ORDER BY o.sold_date) AS channel_rn
      , SUM(o.amount_revenue_sold) OVER (PARTITION BY o.customer_id_edw)                             AS lifetime_revenue
      , SUM(o.amount_revenue_sold) OVER (PARTITION BY o.customer_id_edw, c.customer_category)        AS channel_revenue
      FROM
        bridge.orders o
        LEFT JOIN
          dim.channel c
          ON o.channel = c.name
        LEFT JOIN
          fact.customer_ns_map cnm
          ON o.customer_id_ns = cnm.customer_id_ns
      WHERE c.customer_category != 'INDIRECT' --exclude CS/Marketing customers
      )
, shopify_orders AS
    (
      SELECT
        o.customer_id_shopify
      , csm.customer_id_edw
      , MAX(csm.email) OVER (PARTITION BY csm.customer_id_edw )                                        AS email
      , MAX(csm.normalized_phone_number) OVER (PARTITION BY csm.customer_id_edw)                       AS phone_number
      , o.sold_date
      , c.customer_category
      , o.order_id_edw
      , ROW_NUMBER() OVER (PARTITION BY csm.customer_id_edw ORDER BY o.sold_date)                      AS lifetime_rn
      , ROW_NUMBER() OVER (PARTITION BY csm.customer_id_edw, c.customer_category ORDER BY o.sold_date) AS store_rn
      , SUM(o.amount_sales) OVER (PARTITION BY csm.customer_id_edw)                                    AS lifetime_revenue
      , SUM(o.amount_sales) OVER (PARTITION BY csm.customer_id_edw, c.customer_category)               AS store_revenue
      FROM
        fact.shopify_orders o
        LEFT JOIN
          fact.customer_shopify_map csm
          ON csm.id = o.customer_id_shopify
        LEFT JOIN
          dim.channel c
          ON o.store = CASE WHEN c.name = 'goodr.ca' THEN 'Goodr.ca' ELSE c.name END
      )
, final          AS
    (
      SELECT
        n.customer_id_edw
      , n.customer_category
      , n.email
      , n.phone_number
      , MAX(CASE WHEN n.channel_rn = 1 THEN n.order_id_edw ELSE NULL END) AS first_order_id_edw_ns
      , NULL                                                              AS first_order_id_edw_shopify
      , MAX(CASE WHEN n.channel_rn = 1 THEN n.sold_date ELSE NULL END)    AS first_order_date_ns
      , MAX(CASE WHEN n.channel_rn = 2 THEN n.sold_date ELSE NULL END)    AS second_order_date_ns
      , CASE WHEN MAX(n.channel_rn) = 1 THEN TRUE ELSE FALSE END          AS new_customer_flag_ns
      , NULL                                                              AS first_order_date_shopify
      , NULL                                                              AS second_order_date_shopify
      , NULL                                                              AS new_customer_flag_shopify
      , MAX(n.channel_rn)                                                 AS order_count_ns
      , NULL                                                              AS order_count_shopify
      , n.channel_revenue                                                 AS channel_revenue_ns
      , NULL                                                              AS channel_revenue_shopify
      FROM
        ns_orders n
      GROUP BY ALL
      UNION ALL
      SELECT
        s.customer_id_edw
      , s.customer_category
      , s.email
      , s.phone_number
      , NULL                                                            AS first_order_id_edw_ns
      , MAX(CASE WHEN s.store_rn = 1 THEN s.order_id_edw ELSE NULL END) AS first_order_id_edw_shopify
      , NULL                                                            AS first_order_date_ns
      , NULL                                                            AS second_order_date_ns
      , NULL                                                            AS new_customer_flag_ns
      , MAX(CASE WHEN s.store_rn = 1 THEN s.sold_date ELSE NULL END)    AS first_order_date_shopify
      , MAX(CASE WHEN s.store_rn = 2 THEN s.sold_date ELSE NULL END)    AS second_order_date_shopify
      , CASE WHEN MAX(s.store_rn) = 1 THEN TRUE ELSE FALSE END          AS new_customer_flag_shopify
      , NULL                                                            AS order_count_ns
      , MAX(s.store_rn)                                                 AS order_count_shopify
      , NULL                                                            AS channel_revenue_ns
      , s.store_revenue                                                 AS channel_revenue_shopify
      FROM
        shopify_orders s
      GROUP BY ALL
      )
SELECT
  customer_id_edw
, customer_category
, MAX(email)                     AS email
, MAX(phone_number)              AS phone_number
, MAX(first_order_id_edw_ns)      AS first_order_id_edw_ns
, MAX(first_order_id_edw_shopify)      AS first_order_id_edw_shopify
, MAX(first_order_date_ns)       AS first_order_date_ns
, MAX(second_order_date_ns)      AS second_order_date_ns
, MAX(new_customer_flag_ns)      AS new_customer_flag_ns
, MAX(first_order_date_shopify)  AS first_order_date_shopify
, MAX(second_order_date_shopify) AS second_order_date_shopify
, MAX(new_customer_flag_shopify) AS new_customer_flag_shopify
, MAX(order_count_ns)            AS order_count_ns
, MAX(order_count_shopify)       AS order_count_shopify
, MAX(channel_revenue_ns)        AS channel_revenue_ns
, MAX(channel_revenue_shopify)   AS channel_revenue_shopify
FROM
  final f
GROUP BY ALL
ORDER BY customer_id_edw