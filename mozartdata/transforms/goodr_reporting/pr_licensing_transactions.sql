SELECT
  ord.order_id_edw,
  ord.order_id_shopify,
  ord.store,
  ord.transaction_id_ns,
  orders.channel,
  coalesce(items.sku, ordit.sku) AS sku,
  coalesce(items.name, ordit.plain_name) AS display_name,
  items.rate,
  items.quantity_booked, --Since via shopify this is the amount they ordered, not the amount we hypothetically fulfilled, PR wants this
  items.amount_booked,
  ordit.quantity_sold,
  ordit.rate_sold
FROM
  dim.orders ord
  LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = ord.order_id_edw --going here for the order's channel via NS, the shopify store supersedes it for cases where its not in NS
  LEFT OUTER JOIN fact.shopify_order_item items ON items.order_id_edw = ord.order_id_edw
  LEFT OUTER JOIN fact.order_item ordit ON ordit.order_id_edw = ord.order_id_edw
  AND ord.order_id_shopify IS NULL
where  ord.order_id_shopify IS NULL