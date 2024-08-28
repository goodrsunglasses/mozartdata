WITH
  mutually_exclusive AS (
    SELECT --The idea here is that these are the ones we can comfortable combine onto one line per sku, because they either only exist in NS or only in Shopify, orders wise generally its shopify, but for KA its not
      ord.order_id_edw,
      coalesce(ord.order_id_shopify, ord.transaction_id_ns) AS source_id,
      coalesce(ord.store, orders.channel) AS channel,
      coalesce(items.sku, ordit.sku) AS sku,
      coalesce(items.name, ordit.plain_name) AS display_name,
      coalesce(items.rate, ordit.rate_sold) AS rate_sold,
      coalesce(items.quantity_booked, ordit.quantity_sold) AS quantity_sold, --Yes this is confusing, but business wise PR said he wanted the "Booked" from Shopify and "Sold" from NS for like KA together
      coalesce(items.amount_booked, ordit.amount_product_sold) AS amount_sold
    FROM
      dim.orders ord
      LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = ord.order_id_edw --going here for the order's channel via NS, the shopify store supersedes it for cases where its not in NS
      LEFT OUTER JOIN fact.shopify_order_item items ON items.order_id_edw = ord.order_id_edw
      LEFT OUTER JOIN fact.order_item ordit ON ordit.order_id_edw = ord.order_id_edw
      AND ord.order_id_shopify IS NULL
  )