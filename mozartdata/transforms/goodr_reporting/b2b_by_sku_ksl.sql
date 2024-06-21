SELECT
  detail.order_id_edw,
  detail.transaction_created_date_pst as sold_date, --renamed it this because this report only looks at the sold transaction types
  detail.transaction_id_ns,
  detail.record_type,
  detail.product_id_edw,
  detail.customer_id_edw,
  detail.customer_id_ns,
  orders.model AS business_unit,
  orders.channel,
  detail.item_type,
  detail.plain_name,
  prod.sku,
  detail.amount_revenue AS revenue,
  detail.total_quantity,
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
  LEFT OUTER JOIN netsuite.invoiceshippingaddress invaddy ON invaddy.nkey = detail.shippingaddress
  LEFT OUTER JOIN netsuite.cashsaleshippingaddress csaddy ON csaddy.nkey = detail.shippingaddress
  LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = detail.product_id_edw
  LEFT OUTER JOIN fact.customer_ns_map nsmap ON nsmap.customer_id_ns = detail.customer_id_ns --Doing a straight join as this entire report is NS based and a couple b2b customers have splayed customer info 
WHERE
detail.product_id_edw is not null and orders.b2b_d2c = 'B2B'
  AND detail.record_type IN ('cashsale', 'invoice')