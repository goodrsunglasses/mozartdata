SELECT
  shop.id shopify_id,
  shop.name order_number,
  tag.value tag,
  tran.authorization,
  shop.financial_status,
  shop.fulfillment_status,
  stord.status stord_status,
  line.transaction_status_ns,
  item.sku,
  item.plain_name,
  quantity_booked salesorder_quantity,
  amount_booked salesorder_netamount,
  quantity_backordered,
  quantity_invoiced,
  loc.name location
FROM
  shopify."ORDER" shop
  LEFT OUTER JOIN dim.orders orders ON orders.d2c_shopify_id = shop.id
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 stord ON stord.order_id = orders.stord_id
  left outer join fact.order_line line on line.transaction_id_ns = orders.transaction_id_ns
  left outer join fact.order_item item on item.order_id_edw = shop.name
  left outer join fact.order_item_detail detail on (detail.item_id_ns = item.item_id_ns and detail.transaction_id_ns = line.transaction_id_ns)
 left outer join shopify.order_tag tag on tag.order_id = shop.id
 left outer join shopify.transaction tran on tran.order_id = shop.id
  left outer join netsuite.transactionline tranline on (tranline.transaction = line.transaction_id_ns and tranline.item=item.item_id_ns)
  left outer join dim.location loc on loc.location_id_ns = tranline.location
WHERE
  shop.created_at >= CURRENT_DATE()-30 and item.plain_name not in ('Tax','Shipping')