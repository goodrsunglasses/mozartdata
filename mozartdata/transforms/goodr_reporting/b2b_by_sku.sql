WITH
  booked_shipping AS (
    --Did quick QC on this, no dupes however this is a ad hoc super fast patch and im not proud of it.
    SELECT
      line.order_id_edw,
      addy.country,
      addy.state,
      addy.city,
      addy.zip,
      addy.addr1,
      addy.addr2,
      addy.addr3
    FROM
      fact.order_line line
      LEFT OUTER JOIN netsuite.salesordershippingaddress addy ON addy.nkey = line.shipping_address_ns
    WHERE
      line.record_type = 'salesorder'
  )
SELECT
  o.order_id_edw,
  o.sold_date,
  o.booked_date,
  o.order_id_ns,
  o.model AS business_unit,
  o.channel,
  addy.country,
  addy.state,
  addy.city,
  addy.zip,
  addy.addr1,
  addy.addr2,
  addy.addr3,
  oi.order_item_id,
  oi.product_id_edw,
  oi.item_id_ns,
  oi.sku,
  oi.plain_name,
  oi.quantity_booked,
  oi.quantity_sold,
  oi.quantity_fulfilled,
  oi.quantity_refunded,
  oi.amount_revenue_booked,
  oi.revenue,
  oi.amount_revenue_refunded,
  p.family AS model,
  p.stage,
  p.collection,
  p.merchandise_class,
  p.merchandise_department,
  p.merchandise_division,
  o.customer_id_edw,
  c.customer_name,
  c.primary_sport,
  c.secondary_sport,
  c.tertiary_sport,
  c.tier,
  c.doors,
  c.buyer_name,
  c.buyer_email,
  c.pop,
  c.logistics
FROM
  fact.order_item oi
  LEFT JOIN fact.orders o ON o.order_id_edw = oi.order_id_edw
  LEFT JOIN dim.product p ON p.product_id_edw = oi.product_id_edw
  LEFT JOIN fact.customer_ns_map c ON o.customer_id_edw = c.customer_id_edw
  LEFT OUTER JOIN booked_shipping addy ON addy.order_id_edw = oi.order_id_edw
WHERE
  o.b2b_d2c = 'B2B'
  AND oi.product_id_edw IS NOT NULL
----------------------------------
--CTE for future addition
-- with  fulfilled AS (
--     SELECT
--       oid.order_id_edw,
--        addy.country,
--       addy.state,
--       addy.city,
--       addy.zip,
--       addy.addr1,
--       addy.addr2,
--       addy.addr3,
--       oid.product_id_edw,
--       oid.item_id_ns,
--       CONCAT(oid.order_id_edw, '_', oid.item_id_ns) AS order_item_id,
--       oid.plain_name,
--       COALESCE(oid.total_quantity,0) AS quantity_fulfilled,
--       COALESCE(oid.rate,0) AS rate_fulfilled,
--       COALESCE(oid.amount_cogs,0) AS amount_cogs_fulfilled
--     FROM
--       fact.order_item_detail oid
--     left outer join netsuite.transaction tran on tran.id = oid.TRANSACTION_ID_NS
--     LEFT OUTER JOIN netsuite.salesordershippingaddress addy ON addy.nkey = tran.SHIPPINGADDRESS
--     WHERE
--       oid.record_type = 'itemfulfillment'
--   )