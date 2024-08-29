WITH
  shopify_refunds ( --we dont yet have this as a fact table so here it is 
    SELECT
      refund_id,
      id,
      quantity,
      subtotal,
      order_line_id
  from shopify.order_line_refund
  union all 
      SELECT
      refund_id,
      id,
      quantity,
      subtotal,
      order_line_id
  from specialty_shopify.order_line_refund
  union all 
      SELECT
      refund_id,
      id,
      quantity,
      subtotal,
      order_line_id
  from sellgoodr_canada_shopify.order_line_refund
  union all 
      SELECT
      refund_id,
      id,
      quantity,
      subtotal,
      order_line_id
  from goodr_canada_shopify.order_line_refund
  union all
        SELECT
      refund_id,
      id,
      quantity,
      subtotal,
      order_line_id
  from cabana.order_line_refund
 
  ) distinct_skus AS ( --The idea here is to select a distinct list of all the SKU's in a given order from both NS and shopify to later join back to, JUST in case its in one but not the other
    SELECT DISTINCT
      *
    FROM
      (
        SELECT
          order_id_edw,
          sku,
          name AS display_name
        FROM
          fact.shopify_order_item
        UNION ALL
        SELECT
          order_id_edw,
          sku,
          plain_name
        FROM
          fact.order_item
      )
  ),
  joined AS (
    SELECT
      distinct_skus.*,
      items.store AS shopify_store,
      orders.channel AS ns_channel,
      ordit.rate_sold ns_rate_sold,
      ordit.quantity_sold ns_quantity_sold,
      ordit.amount_product_sold ns_amount_sold,
      ordit.amount_discount_sold AS ns_amount_discount_sold,
      ordit.amount_product_refunded AS ns_amount_product_refunded,
      ordit.amount_product_sold + ordit.amount_product_refunded AS ns_net_sales,
      ns_net_sales - ordit.amount_discount_sold AS ns_net_sales_no_discount,
      items.rate,
      items.quantity_booked,
      items.amount_booked,
    FROM
      distinct_skus
      LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = distinct_skus.order_id_edw --for NS channel
      LEFT OUTER JOIN fact.order_item ordit ON (
        ordit.sku = distinct_skus.sku
        AND ordit.order_id_edw = distinct_skus.order_id_edw
      )
      LEFT OUTER JOIN fact.shopify_order_item items ON (
        items.sku = distinct_skus.sku
        AND items.order_id_edw = distinct_skus.order_id_edw
      )
    WHERE
      distinct_skus.sku IS NOT NULL
  )
SELECT
  *
FROM
  joined
WHERE
  order_id_edw = 'SG-100163'
  -- SELECT
  --   mutually_exclusive.order_id_edw,
  --   mutually_exclusive.source_id,
  --   mutually_exclusive.source_system,
  --   mutually_exclusive.channel,
  --   mutually_exclusive.sku,
  --   mutually_exclusive.display_name,
  --   prod.family,
  --   map.licensor,
  --   prod.collection,
  --   mutually_exclusive.rate_sold,
  --   mutually_exclusive.quantity_sold,
  --   mutually_exclusive.combined_amount_sold,
  --   ordit.amount_discount_sold AS ns_amount_discount_sold,
  --   ordit.amount_product_refunded AS ns_amount_product_refunded,
  --   ordit.amount_product_sold + ordit.amount_product_refunded AS ns_net_sales,
  --   ns_net_sales - ordit.amount_discount_sold AS ns_net_sales_no_discount
  -- FROM
  --   mutually_exclusive
  --   LEFT OUTER JOIN dim.product prod ON prod.sku = mutually_exclusive.sku
  --   LEFT OUTER JOIN fact.order_item ordit ON (
  --     ordit.sku = mutually_exclusive.sku
  --     AND ordit.order_id_edw = mutually_exclusive.order_id_edw
  --   ) --Rejoin because while its cool to see shopify data primarily, I wanna also always show some NS data
  --   LEFT OUTER JOIN google_sheets.licensing_sku_mapping map ON map.sku = mutually_exclusive.sku
  -- WHERE
  --   family = 'LICENSING'