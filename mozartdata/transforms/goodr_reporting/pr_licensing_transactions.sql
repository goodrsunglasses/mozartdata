SELECT
  ord.order_id_edw,
  ord.order_id_shopify,
  ord.store,
  ord.transaction_id_ns,
  orders.channel,
  items.sku,
  items.name,
  items.rate,
  items.quantity_booked, --Since via shopify this is the amount they ordered, not the amount we hypothetically fulfilled, PR wants this
  items.amount_booked
FROM
  dim.orders ord
  LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = ord.order_id_edw --going here for the order's channel via NS, the shopify store supersedes it for cases where its not in NS
  LEFT OUTER JOIN fact.shopify_order_item items ON items.order_id_edw = ord.order_id_edw