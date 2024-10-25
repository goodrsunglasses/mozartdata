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
  ),
  parents AS ( -- select just the parents from fact order line to join after, this is a cte because filtering the entire query for just parent = true ignores the ones that dont come from NS
    SELECT
      order_id_edw,
      transaction_id_ns,
      order_id_ns
    FROM
      fact.order_line
    WHERE
      is_parent = TRUE
  )
  --Joined to the staged (often unioned) fact tables then provided a source column just in case since an order can be sourced from multiple shopify stores, and shipments from shipstation/stord
SELECT
  orders.order_id_edw,
  parents.order_id_ns,
  shopify.order_id_shopify,
  shopify.store,
  parents.transaction_id_ns,
  stord.order_id stord_id,
  CASE
    WHEN shipstation.ordernumber IS NOT NULL THEN MD5(
      LISTAGG(shipstation.orderid, '_') WITHIN GROUP (
        ORDER BY
          shipstation.orderid
      )
    )
    ELSE NULL
  END AS shipstation_id --done as per the exact same logic on fact.fulfillment_order, in order to get shipstation's order's tables down to one row per order number.
FROM
  orders
  LEFT OUTER JOIN fact.shopify_orders shopify ON shopify.order_id_edw = orders.order_id_edw
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 stord ON stord.order_number = orders.order_id_edw
  LEFT OUTER JOIN shipstation_portable.shipstation_orders_8589936627 shipstation ON shipstation.ordernumber = orders.order_id_edw
  LEFT OUTER JOIN parents ON parents.order_id_edw = orders.order_id_edw
GROUP BY
  orders.order_id_edw,
  shipstation.ordernumber,
  shopify.order_id_shopify,
  shopify.store,
  transaction_id_ns,
  stord_id,
  order_id_ns