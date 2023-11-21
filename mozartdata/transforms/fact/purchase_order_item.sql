WITH
  ordered AS (
    SELECT
      order_id_edw,
      product_id_edw,
      item_id_ns,
      CONCAT(order_id_edw, '_', item_id_ns) AS order_item_id,
      plain_name,
      SUM(total_quantity) AS quantity_ordered,
      SUM(rate) AS rate_ordered,
      SUM(net_amount) AS amount_ordered
    FROM
      fact.order_item_detail
    WHERE
      record_type = 'purchaseorder'
    GROUP BY
      order_id_edw,
      product_id_edw,
      item_id_ns,
      order_item_id,
      plain_name
  ),
  billed AS (
    SELECT
      order_id_edw,
      product_id_edw,
      item_id_ns,
      CONCAT(order_id_edw, '_', item_id_ns) AS order_item_id,
      plain_name,
      SUM(total_quantity) AS quantity_billed,
      SUM(rate) AS rate_billed,
      SUM(net_amount) AS amount_billed
    FROM
      fact.order_item_detail
    WHERE
      record_type = 'vendorbill'
    GROUP BY
      order_id_edw,
      product_id_edw,
      item_id_ns,
      order_item_id,
      plain_name
  ),
  received AS (
    SELECT
      order_id_edw,
      product_id_edw,
      item_id_ns,
      CONCAT(order_id_edw, '_', item_id_ns) AS order_item_id,
      plain_name,
      SUM(total_quantity) AS quantity_received,
      SUM(rate) AS rate_received,
      SUM(net_amount) AS amount_received
    FROM
      fact.order_item_detail
    WHERE
      record_type = 'itemreceipt'
    GROUP BY
      order_id_edw,
      product_id_edw,
      item_id_ns,
      order_item_id,
      plain_name
  )
SELECT DISTINCT
  detail.order_id_edw,
  CONCAT(detail.order_id_edw, '_', detail.item_id_ns) AS order_item_id,
  detail.product_id_edw,
  detail.item_id_ns,
  p.sku,
  detail.plain_name,
  product.family,
  quantity_ordered,
  quantity_billed,
  quantity_received,
  rate_ordered,
  rate_billed,
  rate_received,
  amount_ordered,
  amount_billed,
  amount_received
FROM
  fact.order_item_detail detail
  LEFT OUTER JOIN dim.product p ON
    p.product_id_edw = detail.item_id_ns
  LEFT OUTER JOIN ordered ON (
    ordered.order_id_edw = detail.order_id_edw
    AND ordered.item_id_ns = detail.item_id_ns
  )
  LEFT OUTER JOIN billed ON (
    billed.order_id_edw = detail.order_id_edw
    AND billed.item_id_ns = detail.item_id_ns
  )
  LEFT OUTER JOIN received ON (
    received.order_id_edw = detail.order_id_edw
    AND received.item_id_ns = detail.item_id_ns
  )
  LEFT OUTER JOIN dim.product product ON product.item_id_ns = detail.item_id_ns
WHERE
  detail.record_type IN ('vendorbill', 'itemreciept', 'purchaseorder')
ORDER BY
  detail.order_id_edw