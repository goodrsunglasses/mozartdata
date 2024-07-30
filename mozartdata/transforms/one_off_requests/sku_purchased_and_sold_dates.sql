SELECT
  p.item_id_ns,
  p.display_name,
  p.sku,
  p.family,
  p.collection,
  p.stage,
  p.merchandise_department,
  p.merchandise_class,
  p.product_id_edw,
  min(po.purchase_date) AS earliest_po_date,
  max(po.purchase_date) AS latest_po_date,
  min(o.sold_date) as earliest_order_date,
  max(o.sold_date) as latest_order_date
FROM
  dim.product p
  LEFT JOIN fact.purchase_order_item poi on p.item_id_ns = poi.item_id_ns
  LEFT JOIN fact.purchase_orders po on po.order_id_edw = poi.order_id_edw
  left join fact.order_item oi on p.item_id_ns = oi.item_id_ns  --- does not take channel into account
  left join fact.orders o on o.order_id_edw = oi.order_id_edw
GROUP BY
  all