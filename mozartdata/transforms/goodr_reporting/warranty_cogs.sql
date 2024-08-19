WITH
  --- CTE to get COGS for CS orders (less is_exchange = true)
  cte_cs AS (
    SELECT DISTINCT
      gl.order_id_edw,
      gl.order_id_ns AS cs_order_id_ns,
      gl.transaction_number_ns,
      gl.channel,
      gl.transaction_date,
      gl.posting_period,
      gl.net_amount AS cogs,
      p.display_name
    FROM
      fact.gl_transaction gl
      LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
      LEFT JOIN fact.orders o ON o.order_id_ns = gl.order_id_ns
    WHERE
      gl.account_number = 5000
      AND (
        gl.order_id_ns ILIKE 'CI%'
        OR gl.order_id_ns ILIKE 'CS%'
      )
      AND posting_flag
      AND o.is_exchange = 'false'
  ),
  --- CTE to select the order_id_ns for warranties via Shopify (returnlogic)
  cte_rma_ids AS (
    SELECT DISTINCT
      o.order_id_ns
    FROM
      fact.orders o
    WHERE
      o.is_exchange = 'false'
  ),
  --- CTE for COGS of returnlogic warranties, excluding orders already in cte_cs
  cte_returnlogic AS (
    SELECT DISTINCT
      gl.order_id_edw,
      gl.order_id_ns AS returnlogic_order_id_ns,
      gl.transaction_number_ns,
      gl.channel,
      gl.transaction_date,
      gl.posting_period,
      gl.net_amount AS cogs,
      p.display_name
    FROM
      fact.gl_transaction gl
      LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
      INNER JOIN cte_rma_ids id ON id.order_id_ns = gl.order_id_ns
    WHERE
      gl.account_number = 5000
      AND posting_flag
      AND NOT EXISTS (
        SELECT
          1
        FROM
          cte_cs cs
        WHERE
          cs.cs_order_id_ns = gl.order_id_ns
      )
  ),
  --- CTE to select the order_id_ns for warranties via Shopify (parcellab)
  cte_shopify_warranty_ids AS (
    SELECT DISTINCT
      so.name
    FROM
      shopify."ORDER" so
      LEFT JOIN shopify.discount_application d ON so.id = d.order_id
    WHERE
      d.description ILIKE 'war%'
      OR d.description ILIKE 'exc%'
    UNION
    SELECT DISTINCT
      so.name
    FROM
      goodr_canada_shopify."ORDER" so
      LEFT JOIN goodr_canada_shopify.discount_application d ON so.id = d.order_id
    WHERE
      d.description ILIKE 'war%'
      OR d.description ILIKE 'exc%'
  ),
  --- CTE for COGS of shopify warranties, excluding orders already in cte_cs or cte_returnlogic
  cte_shopify AS (
    SELECT DISTINCT
      gl.order_id_edw,
      gl.order_id_ns AS shopify_order_id_ns,
      gl.transaction_number_ns,
      gl.channel,
      gl.transaction_date,
      gl.posting_period,
      gl.net_amount AS cogs,
      p.display_name
    FROM
      fact.gl_transaction gl
      LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
      INNER JOIN cte_shopify_warranty_ids id ON id.name = gl.order_id_ns
    WHERE
      gl.account_number = 5000
      AND posting_flag
      AND NOT EXISTS (
        SELECT
          1
        FROM
          cte_cs cs
        WHERE
          cs.cs_order_id_ns = gl.order_id_ns
      )
      AND NOT EXISTS (
        SELECT
          1
        FROM
          cte_returnlogic rl
        WHERE
          rl.returnlogic_order_id_ns = gl.order_id_ns
      )
  )
  --- Combine all warranties without double-counting
SELECT
  order_id_edw,
  cs_order_id_ns as order_id_ns,
  transaction_number_ns,
  channel,
  transaction_date,
  posting_period,
  cogs,
  display_name
FROM
  cte_cs
UNION
SELECT
  *
FROM
  cte_returnlogic
UNION
SELECT
  *
FROM
  cte_shopify;