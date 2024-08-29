--Add shopify discounts??
--Maybe Gl transaction accounts?


WITH
  shopify_refunds AS ( --we dont yet have this as a fact table so here it is 
    SELECT -- you have to fuckin do this because for some stupid ass fucking reason shopify splits refund lines out 1 per sku per line example is G1993131
      order_line_id,
      sum(quantity) total_quantity_refunded,
      sum(subtotal) total_amount_refunded
    FROM
      (
        SELECT
          refund_id,
          id,
          quantity,
          subtotal,
          order_line_id
        FROM
          shopify.order_line_refund
        UNION ALL
        SELECT
          refund_id,
          id,
          quantity,
          subtotal,
          order_line_id
        FROM
          specialty_shopify.order_line_refund
        UNION ALL
        SELECT
          refund_id,
          id,
          quantity,
          subtotal,
          order_line_id
        FROM
          sellgoodr_canada_shopify.order_line_refund
        UNION ALL
        SELECT
          refund_id,
          id,
          quantity,
          subtotal,
          order_line_id
        FROM
          goodr_canada_shopify.order_line_refund
        UNION ALL
        SELECT
          refund_id,
          id,
          quantity,
          subtotal,
          order_line_id
        FROM
          cabana.order_line_refund
      )
    GROUP BY
      order_line_id
  ),
  distinct_skus AS ( --The idea here is to select a distinct list of all the SKU's in a given order from both NS and shopify to later join back to, JUST in case its in one but not the other
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
      sold_date AS sold_tran_date,
      booked_date_shopify,
      items.store AS shopify_store,
      orders.channel AS ns_channel,
      ordit.rate_sold ns_rate_sold,
      ordit.quantity_sold ns_quantity_sold,
      ordit.amount_product_sold ns_amount_sold,
      ordit.amount_discount_sold AS ns_amount_discount_sold,
      ordit.amount_product_refunded AS ns_amount_product_refunded,
      ordit.amount_product_sold + ordit.amount_product_refunded AS ns_net_sales,
      ns_net_sales - ordit.amount_discount_sold AS ns_net_sales_no_discount,
      items.rate rate_shopify,
      items.quantity_booked quantity_booked_shopify,
      items.amount_booked amount_booked_shopify,
      CASE
        WHEN ref.total_quantity_refunded IS NULL THEN 0
        ELSE ref.total_quantity_refunded
      END AS total_quantity_refunded_shopify,
      CASE
        WHEN ref.total_amount_refunded IS NULL THEN 0
        ELSE ref.total_amount_refunded
      END AS total_amount_refunded_shopify,
      amount_booked_shopify - total_amount_refunded_shopify AS net_sales_shopify
    FROM
      distinct_skus
      LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = distinct_skus.order_id_edw --for NS channel and dates
      LEFT OUTER JOIN fact.order_item ordit ON (
        ordit.sku = distinct_skus.sku
        AND ordit.order_id_edw = distinct_skus.order_id_edw
      )
      LEFT OUTER JOIN fact.shopify_order_item items ON (
        items.sku = distinct_skus.sku
        AND items.order_id_edw = distinct_skus.order_id_edw
      )
      LEFT OUTER JOIN shopify_refunds ref ON ref.order_line_id = items.order_line_id
    WHERE
      distinct_skus.sku IS NOT NULL and orders.order_id_edw is not null and shopify_store != 'Goodrwill'
  )
SELECT
  map.licensor,
  prod.family,
  joined.*,
  concat(joined.sku,'_',joined.order_id_edw) as primary_key_id -- need this for when the dim.product join splays
FROM
  joined
  LEFT OUTER JOIN dim.product prod ON prod.sku = joined.sku
  LEFT OUTER JOIN google_sheets.licensing_sku_mapping map ON map.sku = joined.sku
WHERE
  family= 'LICENSING'
 

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