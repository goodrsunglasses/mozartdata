WITH
  corrected_skus AS (--fix for stupid -v1 stord skus
    SELECT
      item.*,
      CASE
        WHEN sku LIKE '%-v%' THEN LEFT(
          sku,
          LENGTH(sku) - POSITION('-v' IN REVERSE(sku)) - 3
        )
        ELSE sku
      END AS concat_sku
    FROM
      fact.fulfillment_item item
  )
SELECT
  item.order_id_edw order_number,
  ord.channel,
  ord.location,
  ful.ship_date,
  concat_sku,
  prod.display_name,
  item.quantity_stord quantity_shipped_stord,
  item.quantity_ns quantity_shipped_ns
FROM
  fact.fulfillment_item item
  left outer join corrected_skus on item.fulfillment_item_id = corrected_skus.fulfillment_item_id
  LEFT OUTER JOIN fact.fulfillment ful ON ful.fulfillment_id_edw = item.fulfillment_id_edw
  LEFT OUTER JOIN fact.orders ord ON ord.order_id_edw = ful.order_id_edw
  LEFT OUTER JOIN dim.product prod ON prod.sku = item.sku
WHERE
  item.quantity_stord IS NOT NULL
  AND item.quantity_ns IS NULL
  AND ship_date BETWEEN '2025-01-01T00:00:00' AND '2025-01-31T23:59:59'
  AND channel IS NOT NULL