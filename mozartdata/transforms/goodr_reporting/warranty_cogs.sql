--- get the cogs for CS orders that have warrenty prefixes per the CS ORDER NUMBERS deck (less is_exchange true)
WITH
  cte_cs AS (
    SELECT
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
      left join fact.orders o on o.order_id_ns = gl.order_id_ns
    WHERE
      gl.account_number = 5000
      AND (
        gl.order_id_ns iLIKE 'CI%'
        OR gl.order_id_ns iLIKE 'CS%'
      )
      AND posting_flag
      and o.is_exchange = 'false'
  )
  --- select the order_id_ns's for warrenties that came through shopify (returnlogic) - aka marked with rma
, 
  cte_rma_ids as (
  select 
    o.order_id_ns 
  from 
    fact.orders o
  where is_exchange 
  )
  
  --- get cogs for shopify (returnlogic) warranties
,   cte_returnlogic AS (
    SELECT
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
  )

  --- select the order_id_ns's for warrenties that came through shopify (parcellab)
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
  --- get cogs for shopify (parcellab) warranties
,
  cte_shopify AS (
    SELECT
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
union 
select 
*
from cte_returnlogic