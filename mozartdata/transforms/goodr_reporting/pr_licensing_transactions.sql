WITH
  mutually_exclusive AS (
    SELECT --The idea here is that these are the ones we can comfortable combine onto one line per sku, because they either only exist in NS or only in Shopify, orders wise generally its shopify, but for KA its not
      ord.order_id_edw,
      coalesce(ord.order_id_shopify, ord.transaction_id_ns) AS source_id,
      CASE
        WHEN ord.order_id_shopify IS NULL THEN 'Netsuite'
        ELSE 'Shopify'
      END AS source_system,
      coalesce(ord.store, orders.channel) AS channel,
      coalesce(items.sku, ordit.sku) AS sku,
      coalesce(items.name, ordit.plain_name) AS display_name,
      coalesce(items.rate, ordit.rate_sold) AS rate_sold,
      coalesce(items.quantity_booked, ordit.quantity_sold) AS quantity_sold, --Yes this is confusing, but business wise PR said he wanted the "Booked" from Shopify and "Sold" from NS for like KA together
      coalesce(items.amount_booked, ordit.amount_product_sold) AS combined_amount_sold
    FROM
      dim.orders ord
      LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = ord.order_id_edw --going here for the order's channel via NS, the shopify store supersedes it for cases where its not in NS
      LEFT OUTER JOIN fact.shopify_order_item items ON items.order_id_edw = ord.order_id_edw
      LEFT OUTER JOIN fact.order_item ordit ON ordit.order_id_edw = ord.order_id_edw
      AND ord.order_id_shopify IS NULL
  )
SELECT
  mutually_exclusive.order_id_edw,
  mutually_exclusive.source_id,
  mutually_exclusive.source_system,
  mutually_exclusive.channel,
  mutually_exclusive.sku,
  mutually_exclusive.display_name,
  prod.family,
  prod.collection,
  mutually_exclusive.rate_sold,
  mutually_exclusive.quantity_sold,
  mutually_exclusive.combined_amount_sold,
  ordit.amount_discount_sold,
  ordit.amount_product_refunded,
  ordit.amount_product_sold + ordit.amount_product_refunded AS net_sales,
  net_sales - ordit.amount_discount_sold net_sales_no_discount
FROM
  mutually_exclusive
  LEFT OUTER JOIN dim.product prod ON prod.sku = mutually_exclusive.sku
  LEFT OUTER JOIN fact.order_item ordit ON (
    ordit.sku = mutually_exclusive.sku
    AND ordit.order_id_edw = mutually_exclusive.order_id_edw
  )--Rejoin because while its cool to see shopify data primarily, I wanna also always show some NS data
WHERE
  mutually_exclusive.order_id_edw IN ('G1826015')