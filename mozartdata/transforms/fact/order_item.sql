WITH
  booked AS (
    SELECT
      oid.order_id_edw,
      oid.product_id_edw,
      oid.item_id_ns,
      CONCAT(oid.order_id_edw, '_', oid.item_id_ns) AS order_item_id,
      oid.plain_name,
      SUM(oid.total_quantity) AS quantity_booked,
      SUM(oid.rate) AS rate_booked,
      SUM(oid.amount_revenue) AS amount_revenue_booked,
      SUM(oid.amount_product) AS amount_product_booked,
      SUM(oid.amount_discount) AS amount_discount_booked,
      SUM(oid.amount_shipping) AS amount_shipping_booked,
      SUM(oid.amount_tax) AS amount_tax_booked,
      SUM(oid.amount_paid) AS amount_paid_booked
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
      SUM(oid.total_quantity) AS quantity_sold,
      SUM(oid.rate) AS rate_sold,
      SUM(oid.amount_revenue) AS amount_revenue_sold,
      SUM(oid.amount_product) AS amount_product_sold,
      SUM(oid.amount_discount) AS amount_discount_sold,
      SUM(oid.amount_shipping) AS amount_shipping_sold,
      SUM(oid.amount_tax) AS amount_tax_sold,
      SUM(oid.amount_paid) AS amount_paid_sold,
      SUM(gross_profit_estimate) AS gross_profit_estimate,
      SUM(ABS(cost_estimate)) AS cost_estimate
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
      SUM(oid.total_quantity) AS quantity_fulfilled,
      SUM(oid.rate) AS rate_fulfilled,
      SUM(oid.amount_revenue) AS amount_revenue_fulfilled,
      SUM(oid.amount_product) AS amount_product_fulfilled,
      SUM(oid.amount_discount) AS amount_discount_fulfilled,
      SUM(oid.amount_shipping) AS amount_shipping_fulfilled,
      SUM(oid.amount_tax) AS amount_tax_fulfilled,
      SUM(oid.amount_paid) AS amount_paid_fulfilled,
      SUM(oid.amount_cogs) AS amount_cogs_fulfilled
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
  amount_revenue_fulfilled,
  amount_product_fulfilled,
  amount_discount_fulfilled,
  amount_shipping_fulfilled,
  amount_tax_fulfilled,
  amount_paid_fulfilled,
  amount_cogs_fulfilled,
  refunded.amount_product_refunded,
  refunded.amount_shipping_refunded,
  refunded.amount_revenue_refunded as amount_refunded,
  refunded.amount_tax_refunded,
  sold.amount_revenue_sold+refunded.amount_revenue_refunded as revenue,
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
)

where order_id_edw = 'G2894759'