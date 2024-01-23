WITH
  --starting with selecting all the orders from both Netsuite and Shopify (to catch any that may have not sync'ed to NS)
  orders AS (
    SELECT DISTINCT
      order_id_edw
    FROM
      (
        SELECT DISTINCT
          order_id_edw
        FROM
          fact.order_item_detail
        UNION ALL
        SELECT DISTINCT
          order_id_edw
        FROM
          fact.shopify_order_line
      )
  )
  --Joined to the staged (often unioned) fact tables then provided a source column just in case )since an order can be sourced from multiple shopify stores, and shipments from shipstation/stord
SELECT
  orders.order_id_edw,
  shopify.order_id_shopify,
  shopify.store,
  stord.order_id stord_id,
  shipstation.orderkey shipstation_id
FROM
  orders
  LEFT OUTER JOIN fact.shopify_order_line shopify ON shopify.order_id_edw = orders.order_id_edw
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 stord ON stord.order_number = orders.order_id_edw
  LEFT OUTER JOIN shipstation_portable.shipstation_orders_8589936627 shipstation ON shipstation.ordernumber = orders.order_id_edw