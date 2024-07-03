SELECT DISTINCT
  detail.order_id_edw,
  detail.transaction_created_date_pst AS sold_date, --renamed it this because this report only looks at the sold transaction types
  gltran.date_posted_pst,
  gltran.posting_period,
  gltran.posting_flag,
  detail.transaction_id_ns,
  detail.record_type,
  detail.product_id_edw,
  detail.customer_id_edw,
  detail.customer_id_ns,
  orders.model AS business_unit,
  line.channel,
  channel.customer_category,
  detail.item_type,
  detail.plain_name,
  prod.sku,
  detail.amount_revenue AS revenue,
  CASE
    WHEN plain_name = 'Shipping' THEN 0
    ELSE detail.total_quantity
  END AS quantity_sold,
  prod.family AS model,
  prod.stage,
  prod.collection,
  prod.merchandise_class,
  prod.merchandise_department,
  prod.merchandise_division,
  coalesce(invaddy.country, csaddy.country) AS country,
  coalesce(invaddy.state, csaddy.state) AS state,
  coalesce(invaddy.city, csaddy.city) AS city,
  coalesce(invaddy.zip, csaddy.zip) AS zip,
  coalesce(invaddy.addr1, csaddy.addr1) AS addr1,
  coalesce(invaddy.addr2, csaddy.addr2) AS addr2,
  coalesce(invaddy.addr3, csaddy.addr3) AS addr3,
  nsmap.customer_name,
  nsmap.primary_sport,
  nsmap.secondary_sport,
  nsmap.tertiary_sport,
  nsmap.tier,
  nsmap.doors,
  nsmap.buyer_name,
  nsmap.buyer_email,
  nsmap.pop,
  nsmap.logistics
FROM
  fact.order_item_detail detail
  LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = detail.order_id_edw
  LEFT OUTER JOIN fact.order_line line ON line.transaction_id_ns = detail.transaction_id_ns
  LEFT OUTER JOIN dim.channel channel ON channel.name = line.channel
  LEFT OUTER JOIN netsuite.invoiceshippingaddress invaddy ON invaddy.nkey = detail.shippingaddress
  LEFT OUTER JOIN netsuite.cashsaleshippingaddress csaddy ON csaddy.nkey = detail.shippingaddress
  LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = detail.product_id_edw
  LEFT OUTER JOIN fact.customer_ns_map nsmap ON nsmap.customer_id_ns = detail.customer_id_ns --Doing a straight join as this entire report is NS based and a couple b2b customers have splayed customer info 
  LEFT OUTER JOIN fact.gl_transaction gltran ON gltran.transaction_id_ns = detail.transaction_id_ns
WHERE
  channel.customer_category = 'B2B'
  AND detail.record_type IN ('cashsale', 'invoice', 'cashrefund')
  AND gltran.posting_flag = TRUE
  AND plain_name != 'Tax'