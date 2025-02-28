SELECT DISTINCT
      detail.order_id_edw
    , detail.transaction_date                   AS sold_date --renamed it this because this report only looks at the sold transaction types
    , gltran.date_posted_pst --we don't need this
    , gltran.posting_period
    , gltran.posting_flag --we don't need this
    , detail.transaction_id_ns
    , detail.record_type
    , detail.product_id_edw
    , detail.customer_id_edw
    , detail.customer_id_ns
    , orders.model                              AS business_unit
    , line.channel
    , channel.customer_category
    , detail.item_type
    , detail.plain_name
    , prod.sku
    , detail.amount_revenue                     AS revenue
    , CASE
        WHEN plain_name = 'Shipping' THEN 0
        ELSE detail.total_quantity
        END                                     AS quantity_sold
    , prod.family                               AS model
    , prod.stage
    , prod.collection
    , prod.merchandise_class
    , prod.merchandise_department
    , prod.merchandise_division
    , COALESCE(invaddy.country, csaddy.country) AS country
    , COALESCE(invaddy.state, csaddy.state)     AS state
    , COALESCE(invaddy.city, csaddy.city)       AS city
    , COALESCE(invaddy.zip, csaddy.zip)         AS zip
    , COALESCE(invaddy.addr1, csaddy.addr1)     AS addr1
    , COALESCE(invaddy.addr2, csaddy.addr2)     AS addr2
    , COALESCE(invaddy.addr3, csaddy.addr3)     AS addr3
    , nsmap.customer_name
    , nsmap.primary_sport
    , nsmap.secondary_sport
    , nsmap.tertiary_sport
    , nsmap.tier
    , nsmap.doors
    , nsmap.buyer_name
    , nsmap.buyer_email
    , nsmap.pop
    , nsmap.logistics
    FROM
      fact.order_item_detail detail
      LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = detail.order_id_edw
      LEFT OUTER JOIN fact.order_line line ON line.transaction_id_ns = detail.transaction_id_ns
      LEFT OUTER JOIN dim.channel channel ON channel.name = line.channel
      LEFT OUTER JOIN netsuite.invoiceshippingaddress invaddy ON invaddy.nkey = detail.shippingaddress
      LEFT OUTER JOIN netsuite.cashsaleshippingaddress csaddy ON csaddy.nkey = detail.shippingaddress
      LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = detail.product_id_edw
      LEFT OUTER JOIN fact.customer_ns_map nsmap
                      ON nsmap.customer_id_ns = detail.customer_id_ns --Doing a straight join as this entire report is NS based and a couple b2b customers have splayed customer info
      LEFT OUTER JOIN dev_reporting.gl_transaction gltran ON gltran.transaction_id_ns = detail.transaction_id_ns
    WHERE
        channel.customer_category = 'B2B'
    AND detail.record_type IN ('cashsale', 'invoice', 'cashrefund')
    AND gltran.posting_flag = TRUE
    AND plain_name != 'Tax'
    UNION ALL
    SELECT
      NULL                    AS order_id_edw
    , gltran.transaction_date AS sold_date --renamed it this because this report only looks at the sold transaction types
    , gltran.date_posted_pst --we don't need this
    , gltran.posting_period
    , gltran.posting_flag --we don't need this
    , gltran.transaction_id_ns
    , gltran.record_type
    , gltran.product_id_edw
    , gltran.customer_id_edw
    , gltran.customer_id_ns
    , NULL                    AS business_unit
    , gltran.channel
    , channel.customer_category
    , NULL                    AS item_type
    , NULL                    AS plain_name
    , NULL                    AS sku
    , SUM(gltran.net_amount)  AS revenue
    , NULL                    AS quantity_sold
    , NULL                    AS model
    , NULL                    AS stage
    , NULL                    AS collection
    , NULL                    AS merchandise_class
    , NULL                    AS merchandise_department
    , NULL                    AS merchandise_division
    , NULL                    AS country
    , NULL                    AS state
    , NULL                    AS city
    , NULL                    AS zip
    , NULL                    AS addr1
    , NULL                    AS addr2
    , NULL                    AS addr3
    , 'Report vs GL Variance' AS customer_name
    , NULL                    AS primary_sport
    , NULL                    AS secondary_sport
    , NULL                    AS tertiary_sport
    , NULL                    AS tier
    , NULL                    AS doors
    , NULL                    AS buyer_name
    , NULL                    AS buyer_email
    , NULL                    AS pop
    , NULL                    AS logistics
    FROM
      dev_reporting.gl_transaction gltran
      INNER JOIN
        dim.channel channel
        ON gltran.channel = channel.name
          AND channel.customer_category = 'B2B'
    WHERE
        gltran.posting_flag = TRUE
    AND gltran.account_number LIKE '4%'
    AND gltran.order_id_edw IS NULL
    GROUP BY ALL

--QC of query
--compare this:
select channel, posting_period, sum(revenue) from
  (
    SELECT DISTINCT
      detail.order_id_edw
    , detail.transaction_date                   AS sold_date --renamed it this because this report only looks at the sold transaction types
    , gltran.date_posted_pst --we don't need this
    , gltran.posting_period
    , gltran.posting_flag --we don't need this
    , detail.transaction_id_ns
    , detail.record_type
    , detail.product_id_edw
    , detail.customer_id_edw
    , detail.customer_id_ns
    , orders.model                              AS business_unit
    , line.channel
    , channel.customer_category
    , detail.item_type
    , detail.plain_name
    , prod.sku
    , detail.amount_revenue                     AS revenue
    , CASE
        WHEN plain_name = 'Shipping' THEN 0
        ELSE detail.total_quantity
        END                                     AS quantity_sold
    , prod.family                               AS model
    , prod.stage
    , prod.collection
    , prod.merchandise_class
    , prod.merchandise_department
    , prod.merchandise_division
    , COALESCE(invaddy.country, csaddy.country) AS country
    , COALESCE(invaddy.state, csaddy.state)     AS state
    , COALESCE(invaddy.city, csaddy.city)       AS city
    , COALESCE(invaddy.zip, csaddy.zip)         AS zip
    , COALESCE(invaddy.addr1, csaddy.addr1)     AS addr1
    , COALESCE(invaddy.addr2, csaddy.addr2)     AS addr2
    , COALESCE(invaddy.addr3, csaddy.addr3)     AS addr3
    , nsmap.customer_name
    , nsmap.primary_sport
    , nsmap.secondary_sport
    , nsmap.tertiary_sport
    , nsmap.tier
    , nsmap.doors
    , nsmap.buyer_name
    , nsmap.buyer_email
    , nsmap.pop
    , nsmap.logistics
    FROM
      fact.order_item_detail detail
      LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = detail.order_id_edw
      LEFT OUTER JOIN fact.order_line line ON line.transaction_id_ns = detail.transaction_id_ns
      LEFT OUTER JOIN dim.channel channel ON channel.name = line.channel
      LEFT OUTER JOIN netsuite.invoiceshippingaddress invaddy ON invaddy.nkey = detail.shippingaddress
      LEFT OUTER JOIN netsuite.cashsaleshippingaddress csaddy ON csaddy.nkey = detail.shippingaddress
      LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = detail.product_id_edw
      LEFT OUTER JOIN fact.customer_ns_map nsmap
                      ON nsmap.customer_id_ns = detail.customer_id_ns --Doing a straight join as this entire report is NS based and a couple b2b customers have splayed customer info
      LEFT OUTER JOIN dev_reporting.gl_transaction gltran ON gltran.transaction_id_ns = detail.transaction_id_ns
    WHERE
        channel.customer_category = 'B2B'
    AND detail.record_type IN ('cashsale', 'invoice', 'cashrefund')
    AND gltran.posting_flag = TRUE
    AND plain_name != 'Tax'
    UNION ALL
    SELECT
      NULL                    AS order_id_edw
    , gltran.transaction_date AS sold_date --renamed it this because this report only looks at the sold transaction types
    , gltran.date_posted_pst --we don't need this
    , gltran.posting_period
    , gltran.posting_flag --we don't need this
    , gltran.transaction_id_ns
    , gltran.record_type
    , gltran.product_id_edw
    , gltran.customer_id_edw
    , gltran.customer_id_ns
    , NULL                    AS business_unit
    , gltran.channel
    , channel.customer_category
    , NULL                    AS item_type
    , NULL                    AS plain_name
    , NULL                    AS sku
    , SUM(gltran.net_amount)  AS revenue
    , NULL                    AS quantity_sold
    , NULL                    AS model
    , NULL                    AS stage
    , NULL                    AS collection
    , NULL                    AS merchandise_class
    , NULL                    AS merchandise_department
    , NULL                    AS merchandise_division
    , NULL                    AS country
    , NULL                    AS state
    , NULL                    AS city
    , NULL                    AS zip
    , NULL                    AS addr1
    , NULL                    AS addr2
    , NULL                    AS addr3
    , 'Report vs GL Variance' AS customer_name
    , NULL                    AS primary_sport
    , NULL                    AS secondary_sport
    , NULL                    AS tertiary_sport
    , NULL                    AS tier
    , NULL                    AS doors
    , NULL                    AS buyer_name
    , NULL                    AS buyer_email
    , NULL                    AS pop
    , NULL                    AS logistics
    FROM
      dev_reporting.gl_transaction gltran
      INNER JOIN
        dim.channel channel
        ON gltran.channel = channel.name
          AND channel.customer_category = 'B2B'
    WHERE
        gltran.posting_flag = TRUE
    AND gltran.account_number LIKE '4%'
    AND gltran.order_id_edw IS NULL
    GROUP BY ALL