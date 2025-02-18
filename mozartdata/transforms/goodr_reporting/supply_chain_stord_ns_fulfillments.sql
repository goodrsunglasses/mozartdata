WITH
  cogs_info AS (
    SELECT
      order_id_edw,
      product_id_edw,
      cost_estimate
    FROM
      fact.order_item_detail
    WHERE
      record_type IN ('cashsale', 'invoice')
  ),
  parent_info AS (
    SELECT
      order_id_edw,
      transaction_status_ns
    FROM
      fact.order_line
    WHERE
      is_parent = TRUE
  )
SELECT
  item.order_id_edw order_number,
  transaction_status_ns,
  ord.channel,
  ord.location,
  ful.ship_date AS ship_date_stord,
  REGEXP_REPLACE(item.sku, '-v\\d+$', '') AS fixed_sku,
  prod.display_name,
  item.quantity_stord quantity_shipped_stord,
  cogs_info.cost_estimate,
  quantity_fulfilled_ns
FROM
  fact.fulfillment_item item
  LEFT OUTER JOIN parent_info ON parent_info.order_id_edw = item.order_id_edw
  LEFT OUTER JOIN fact.fulfillment ful ON ful.fulfillment_id_edw = item.fulfillment_id_edw
  LEFT OUTER JOIN fact.orders ord ON ord.order_id_edw = ful.order_id_edw
  LEFT OUTER JOIN dim.product prod ON prod.sku = REGEXP_REPLACE(item.sku, '-v\\d+$', '')
  LEFT OUTER JOIN cogs_info ON cogs_info.product_id_edw = prod.sku
  AND cogs_info.order_id_edw = ord.order_id_edw
WHERE
  quantity_stord IS NOT NULL
  AND fulfillment_date_ns IS NULL
  AND channel IS NOT NULL
  AND transaction_status_ns NOT IN (
    'Sales Order : Billed',
    'Sales Order : Pending Billing',
    'Sales Order : Closed',
    'Sales Order : Cancelled'
  )
  AND date(ship_date) != CURRENT_DATE()
ORDER BY
  ship_date desc