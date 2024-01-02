SELECT
  shop.id shopify_id,
  shop.name order_number,
  tag.value tag,
  shop.financial_status,
  shop.fulfillment_status,
  stord.status stord_status,
  line.transaction_status_ns,
  item.sku,
  item.plain_name,
  quantity_booked salesorder_quantity,
  amount_booked salesorder_netamount,
  quantity_backordered,
  quantity_invoiced
FROM
  shopify."ORDER" shop
  LEFT OUTER JOIN dim.orders orders ON orders.d2c_shopify_id = shop.id
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 stord ON stord.order_id = orders.stord_id
  left outer join fact.order_line line on line.transaction_id_ns = orders.transaction_id_ns
  left outer join fact.order_item item on item.order_id_edw = shop.name
  left outer join fact.order_item_detail detail on (detail.item_id_ns = item.item_id_ns and detail.transaction_id_ns = line.transaction_id_ns)
 left outer join shopify.order_tag tag on tag.order_id = shop.id
WHERE
  shop.created_at >= '2023-01-01T00:00:00Z' and shop.name = 'G2619952' and tag = 'Buy with Prime'