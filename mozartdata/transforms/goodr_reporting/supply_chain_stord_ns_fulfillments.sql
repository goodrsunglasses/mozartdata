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
  )
SELECT
  item.order_id_edw order_number,
  ord.channel,
  ord.location,
  ful.ship_date,
  REGEXP_REPLACE(item.sku, '-v\\d+$', '') AS fixed_sku,
  prod.display_name,
  item.quantity_stord quantity_shipped_stord,
  cogs_info.cost_estimate,
  quantity_fulfilled_ns
FROM
  fact.fulfillment_item item
  LEFT OUTER JOIN fact.fulfillment ful ON ful.fulfillment_id_edw = item.fulfillment_id_edw
  LEFT OUTER JOIN fact.orders ord ON ord.order_id_edw = ful.order_id_edw
  LEFT OUTER JOIN dim.product prod ON prod.sku = REGEXP_REPLACE(item.sku, '-v\\d+$', '')
  left outer join cogs_info on cogs_info.product_id_edw=prod.sku and cogs_info.order_id_edw = ord.order_id_edw
WHERE
  quantity_stord IS NOT NULL
  AND fulfillment_date_ns IS NULL
  AND channel IS NOT NULL
ORDER BY
  ship_date desc