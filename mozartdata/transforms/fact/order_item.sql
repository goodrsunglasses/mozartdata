CREATE OR REPLACE TABLE fact.order_item COPY GRANTS AS
WITH
  booked AS (
    SELECT
      order_id_edw,
      product_id_edw,
      item_id_ns,
      CONCAT(order_id_edw, '_', item_id_ns) AS order_item_id,
      plain_name,
      SUM(total_quantity) AS quantity_booked,
      SUM(rate) AS rate_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN net_amount
          ELSE 0
        END
      ) AS amount_booked,
      SUM(
        CASE
          WHEN plain_name = 'Shipping' THEN net_amount
          ELSE 0
        END
      ) AS shipping_booked,
      SUM(
        CASE
          WHEN plain_name = 'Tax' THEN net_amount
          ELSE 0
        END
      ) AS tax_booked
    FROM
      fact.order_item_detail
    WHERE
      record_type = 'salesorder' and order_id_edw = 'G1701824'
    GROUP BY
      order_id_edw,
      product_id_edw,
      item_id_ns,
      order_item_id,
      plain_name
  ),
  sold AS (
    SELECT
      order_id_edw,
      product_id_edw,
      item_id_ns,
      CONCAT(order_id_edw, '_', item_id_ns) AS order_item_id,
      plain_name,
      SUM(total_quantity) AS quantity_sold,
      SUM(rate) AS rate_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN net_amount
          ELSE 0
        END
      ) AS amount_sold,
      SUM(
        CASE
          WHEN plain_name = 'Shipping' THEN net_amount
          ELSE 0
        END
      ) AS shipping_sold,
      SUM(
        CASE
          WHEN plain_name = 'Tax' THEN net_amount
          ELSE 0
        END
      ) AS tax_sold,
      SUM(gross_profit_estimate) AS gross_profit_estimate,
      SUM(ABS(cost_estimate)) AS cost_estimate
    FROM
      fact.order_item_detail
    WHERE
      record_type IN ('cashsale', 'invoice')
    GROUP BY
      order_id_edw,
      product_id_edw,
      item_id_ns,
      order_item_id,
      plain_name
  ),
  fulfilled AS (
    SELECT
      order_id_edw,
      product_id_edw,
      item_id_ns,
      CONCAT(order_id_edw, '_', item_id_ns) AS order_item_id,
      plain_name,
      SUM(total_quantity) AS quantity_fulfilled,
      SUM(rate) AS rate_fulfilled,
      SUM(net_amount) AS amount_fulfilled
    FROM
      fact.order_item_detail
    WHERE
      record_type = 'itemfulfillment'
    GROUP BY
      order_id_edw,
      product_id_edw,
      item_id_ns,
      order_item_id,
      plain_name
  ),
  refunded AS (
    SELECT
      order_id_edw,
      product_id_edw,
      item_id_ns,
      CONCAT(order_id_edw, '_', item_id_ns) AS order_item_id,
      plain_name,
      SUM(total_quantity) AS quantity_refunded,
      SUM(rate) AS rate_refunded,
      SUM(ABS(net_amount)) AS amount_refunded
    FROM
      fact.order_item_detail
    WHERE
      record_type = 'cashrefund'
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
  amount_booked,
  tax_booked,
  shipping_booked,
  amount_sold,
  tax_sold,
  shipping_sold,
  amount_fulfilled,
  amount_refunded,
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