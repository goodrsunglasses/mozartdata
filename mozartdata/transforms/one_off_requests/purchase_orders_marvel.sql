SELECT
  poi.*,
  p.collection,
  po.purchase_date,
  po.fulfillment_date as recieved_date
FROM
  fact.purchase_order_item poi
  LEFT JOIN dim.product p ON p.product_id_edw = poi.product_id_edw
  left join fact.purchase_orders po on po.order_id_edw = poi.order_id_edw
WHERE
  (
    p.sku IN (
      'G00075-OG-PK1-RF',
      'G00076-OG-GB3-RF',
      'G00077-OG-GD6-RF',
      'G00093-OG-BK1-NR',
      'G00094-OG-BK1-NR',
      'G00095-OG-LLB2-RF',
      'G00096-OG-PR2-RF',
      'G00097-OG-GD7-RF',
      'G00098-OG-BL4-RF',
      'G00103-OG-BK1-NR',
      'G00104-OG-BK1-NR',
      'G00105-OG-BK1-NR',
      'G00106-OG-BK1-NR',
      'G00107-OG-BK1-NR',
      'G00108-OG-BK1-NR',
      'G00125-OG-BL4-RF',
      'G00126-OG-BL4-RF',
      'G00127-OG-LLB2-RF',
      'G00148-OG-PP1-RF',
      'G00149-OG-GD6-RF',
      'G00182-OG-PR2-RF',
      'G00183-OG-GD6-RF',
      'G00184-OG-GD7-RF',
      'G00293-OG-BO1-RF',
      'G00294-OG-BK1-GR',
      'G00295-OG-GB3-RF'
    )
  )
  AND p.family = 'LICENSING'
ORDER BY
  order_id_edw