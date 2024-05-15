WITH
  booked AS (
    SELECT
      oid.order_id_edw,
      oid.product_id_edw,
      oid.item_id_ns,
      CONCAT(oid.order_id_edw, '_', oid.item_id_ns) AS order_item_id,
      oid.plain_name,
      COALESCE(SUM(oid.total_quantity),0) AS quantity_booked,
      COALESCE(SUM(oid.rate),0) AS rate_booked,
      COALESCE(SUM(oid.amount_revenue),0) AS amount_revenue_booked,
      COALESCE(SUM(oid.amount_product),0) AS amount_product_booked,
      COALESCE(SUM(oid.amount_discount),0) AS amount_discount_booked,
      COALESCE(SUM(oid.amount_shipping),0) AS amount_shipping_booked,
      COALESCE(SUM(oid.amount_tax),0) AS amount_tax_booked,
      COALESCE(SUM(oid.amount_paid),0) AS amount_paid_booked
    FROM
      fact.order_item_detail oid
    WHERE
      oid.record_type = 'salesorder'
    GROUP BY
      oid.order_id_edw,
      oid.product_id_edw,
      oid.item_id_ns,
      order_item_id,
      oid.plain_name
  ),
  sold AS (
    SELECT
      oid.order_id_edw,
      oid.product_id_edw,
      oid.item_id_ns,
      CONCAT(oid.order_id_edw, '_', oid.item_id_ns) AS order_item_id,
      oid.plain_name,
      COALESCE(SUM(oid.total_quantity),0) AS quantity_sold,
      COALESCE(SUM(oid.rate),0) AS rate_sold,
      COALESCE(SUM(oid.amount_revenue),0) AS amount_revenue_sold,
      COALESCE(SUM(oid.amount_product),0) AS amount_product_sold,
      COALESCE(SUM(oid.amount_discount),0) AS amount_discount_sold,
      COALESCE(SUM(oid.amount_shipping),0) AS amount_shipping_sold,
      COALESCE(SUM(oid.amount_tax),0) AS amount_tax_sold,
      COALESCE(SUM(oid.amount_paid),0) AS amount_paid_sold,
      COALESCE(SUM(gross_profit_estimate),0) AS gross_profit_estimate,
      COALESCE(SUM(ABS(cost_estimate)),0) AS cost_estimate
    FROM
      fact.order_item_detail oid
    WHERE
      oid.record_type IN ('cashsale', 'invoice')
    GROUP BY
      oid.order_id_edw,
      oid.product_id_edw,
      oid.item_id_ns,
      order_item_id,
      oid.plain_name
  ),
  fulfilled AS (
    SELECT
      oid.order_id_edw,
      oid.product_id_edw,
      oid.item_id_ns,
      CONCAT(oid.order_id_edw, '_', oid.item_id_ns) AS order_item_id,
      oid.plain_name,
      COALESCE(SUM(oid.total_quantity),0) AS quantity_fulfilled,
      COALESCE(SUM(oid.rate),0) AS rate_fulfilled,
      COALESCE(SUM(oid.amount_cogs),0) AS amount_cogs_fulfilled
    FROM
      fact.order_item_detail oid
    WHERE
      oid.record_type = 'itemfulfillment'
    GROUP BY
      oid.order_id_edw,
      oid.product_id_edw,
      oid.item_id_ns,
      order_item_id,
      oid.plain_name
  ),
  refunded AS (
    SELECT
      order_id_edw,
      product_id_edw,
      item_id_ns,
      CONCAT(order_id_edw, '_', item_id_ns) AS order_item_id,
      plain_name,
      SUM(oid.total_quantity) AS quantity_refunded,
      SUM(oid.rate) AS rate_refunded,
      COALESCE(SUM(CASE WHEN plain_name NOT IN ('Sales Tax','Tax', 'Shipping') THEN oid.amount_refunded ELSE 0 END),0) AS amount_product_refunded,
      COALESCE(SUM(CASE WHEN plain_name NOT IN ('Sales Tax','Tax') THEN oid.amount_revenue ELSE 0 END),0) AS amount_revenue_refunded,
      COALESCE(SUM(CASE WHEN plain_name = 'Shipping' THEN oid.amount_refunded ELSE 0 END),0) AS amount_shipping_refunded,
      COALESCE(SUM(CASE WHEN plain_name in ('Sales Tax','Tax') THEN oid.amount_refunded ELSE 0 END),0) AS amount_tax_refunded
    FROM
      fact.order_item_detail oid
    WHERE
      record_type in ('cashrefund')
    GROUP BY
      order_id_edw,
      product_id_edw,
      item_id_ns,
      order_item_id,
      plain_name
  )
SELECT DISTINCT
  detail.order_id_edw,
  detail.order_id_ns,
  CONCAT(detail.order_id_edw, '_', detail.item_id_ns) AS order_item_id,
  detail.product_id_edw,
  detail.item_id_ns,
  p.sku,
  detail.plain_name,
  quantity_booked,
  quantity_sold,
  quantity_fulfilled,
  quantity_refunded,
  rate_booked,
  rate_sold,
  rate_fulfilled,
  rate_refunded,
  amount_revenue_booked,
  amount_product_booked,
  amount_discount_booked,
  amount_shipping_booked,
  amount_tax_booked,
  amount_paid_booked,
  amount_revenue_sold,
  amount_product_sold,
  amount_discount_sold,
  amount_shipping_sold,
  amount_tax_sold,
  amount_paid_sold,
  amount_cogs_fulfilled,
  refunded.amount_revenue_refunded,
  refunded.amount_product_refunded,
  refunded.amount_shipping_refunded,
  refunded.amount_tax_refunded,
  coalesce(sold.amount_revenue_sold,0)+coalesce(refunded.amount_revenue_refunded,0) as revenue,
  sold.gross_profit_estimate AS gross_profit_estimate,
  sold.cost_estimate AS cost_estimate
FROM
      fact.order_item_detail detail
  LEFT OUTER JOIN dim.product p ON p.product_id_edw = detail.item_id_ns
  LEFT OUTER JOIN booked ON (
    booked.order_id_edw = detail.order_id_edw
    AND booked.item_id_ns = detail.item_id_ns
  )
  LEFT OUTER JOIN sold ON (
    sold.order_id_edw = detail.order_id_edw
    AND sold.item_id_ns = detail.item_id_ns
  )
  LEFT OUTER JOIN fulfilled ON (
    fulfilled.order_id_edw = detail.order_id_edw
    AND fulfilled.item_id_ns = detail.item_id_ns
  )
  LEFT OUTER JOIN refunded ON (
    refunded.order_id_edw = detail.order_id_edw
    AND refunded.item_id_ns = detail.item_id_ns
  )
WHERE
  detail.record_type IN (
    'cashsale',
    'itemfulfillment',
    'salesorder',
    'cashrefund',
    'invoice'
  )
ORDER BY
  detail.order_id_edw