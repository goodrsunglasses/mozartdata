SELECT
  poi.*,
  p.sku,
  p.item_id_ns,
  p.collection
FROM
  fact.purchase_order_item poi
  LEFT JOIN dim.product p ON p.product_id_edw = poi.product_id_edw
WHERE
  (
    p.collection ILIKE '%MARVEL%'
    OR p.collection ILIKE '%AVENGERS%'
  )
  AND p.family = 'LICENSING'
order by order_id_edw