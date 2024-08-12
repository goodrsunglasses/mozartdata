--- get the cogs for CS orders that have warrenty prefixes per the CS ORDER NUMBERS deck
WITH
  cte_cs AS (
    SELECT
      gl.order_id_edw,
      gl.order_id_ns,
      gl.transaction_number_ns,
      gl.channel,
      gl.transaction_date,
      gl.posting_period,
      gl.net_amount AS cogs,
      p.display_name
    FROM
      fact.gl_transaction gl
      LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
    WHERE
      gl.account_number = 5000
      AND (
        order_id_ns LIKE 'CI%'
        OR order_id_ns LIKE 'CS-DMG%'
      )
      AND posting_flag
  )
  --- select the order_id_ns's for warrenties that came through shopify
,
  cte_shopify_warranty_ids AS (
    SELECT
      name
    FROM
      shopify."ORDER" so
      LEFT JOIN shopify.discount_application d ON so.id = d.order_id
    WHERE
      (
        d.description ILIKE 'war%'
        OR d.description ILIKE 'exc%'
      )
    UNION
    SELECT
      name
    FROM
      goodr_canada_shopify."ORDER" so
      LEFT JOIN goodr_canada_shopify.discount_application d ON so.id = d.order_id
    WHERE
      (
        d.description ILIKE 'war%'
        OR d.description ILIKE 'exc%'
      )
  )
  --- get cogs for shopify warranties
,
  cte_shopify AS (
    SELECT
      gl.order_id_edw,
      gl.order_id_ns,
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
  )
  --- show all warranties
SELECT
  *
FROM
  cte_cs
UNION
SELECT
  *
FROM
  cte_shopify