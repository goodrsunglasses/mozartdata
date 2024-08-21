--- get the cogs for orders that are assocaited with the defectives/damages gl account 4220
with cte_defectives as (
  SELECT
  gl.channel,
  gl.posting_period,
  gl.order_id_ns,
  gl.transaction_number_ns,
  gl.transaction_line_id,
  p.sku,
  gl.item_id_ns,
  p.display_name,
  gl.net_amount AS cogs
FROM
  fact.gl_transaction gl
  LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
  INNER JOIN (
    SELECT order_id_ns
    FROM fact.gl_transaction
    WHERE account_number = 4220
  ) defective_ids ON defective_ids.order_id_ns = gl.order_id_ns
WHERE
  gl.account_number = 5000
  AND gl.posting_flag
  AND gl.posting_period LIKE '%2024'
ORDER BY
  gl.posting_period,
  gl.channel,
  p.sku
  )

--- get the cogs for CS orders (have CI or CS-DMG prefixes per the CS ORDER NUMBERS deck)
,
  cte_cs AS (
    SELECT
      gl.order_id_edw,
      gl.order_id_ns AS cs_order_id_ns,
      gl.transaction_number_ns,
      gl.transaction_line_id,
      gl.channel,
      gl.transaction_date,
      gl.posting_period,
      gl.net_amount AS cogs,
      gl.item_id_ns,
      p.display_name,
      p.sku
    FROM
      fact.gl_transaction gl
      LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
      left join fact.orders o on o.order_id_ns = gl.order_id_ns
    WHERE
      gl.account_number = 5000
      AND (
        gl.order_id_ns iLIKE 'CI%'
        OR gl.order_id_ns iLIKE 'CS-DMG%'
      )
      AND posting_flag
  )

--- get the cogs for returnlogic orders (where is_exchange is true)
, cte_rl as (
  SELECT
  gl.order_id_edw,
  gl.order_id_ns AS returnlogic_order_id_ns,
  gl.transaction_number_ns,
  gl.transaction_line_id,
  gl.channel,
  gl.transaction_date,
  gl.posting_period,
  gl.net_amount AS cogs,
  gl.item_id_ns,
  p.display_name,
  p.sku
FROM
  fact.gl_transaction gl
  LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
  INNER JOIN (
    SELECT order_id_ns
    FROM fact.orders
    WHERE is_exchange
  ) cte_rma_ids ON cte_rma_ids.order_id_ns = gl.order_id_ns
WHERE
  gl.account_number = 5000
  AND gl.posting_flag
  )
, 
---- get the cogs for parcellab orders (where war / exc is in the shopify discount code)
 cte_pl as (
SELECT
  gl.order_id_edw,
  gl.order_id_ns AS shopify_order_id_ns,
  gl.transaction_number_ns,
  gl.transaction_line_id,
  gl.channel,
  gl.transaction_date,
  gl.posting_period,
  gl.item_id_ns,
  gl.net_amount AS cogs,
  p.display_name,
  p.sku
FROM
  fact.gl_transaction gl
  LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
  INNER JOIN (
    SELECT
      name
    FROM
      shopify."ORDER" so
      LEFT JOIN shopify.discount_application d ON so.id = d.order_id
    WHERE
      d.description ILIKE 'war%'
      OR d.description ILIKE 'exc%'
    
    UNION
    
    SELECT
      name
    FROM
      goodr_canada_shopify."ORDER" so
      LEFT JOIN goodr_canada_shopify.discount_application d ON so.id = d.order_id
    WHERE
      d.description ILIKE 'war%'
      OR d.description ILIKE 'exc%'
  ) cte_shopify_warranty_ids ON cte_shopify_warranty_ids.name = gl.order_id_ns
WHERE
  gl.account_number = 5000
  AND gl.posting_flag 
  )

--- THIS IS WHERE IT STARTS BEING WRONG
--- 
, cte_combined_ids as(
  select distinct * 
  from 
    (select transaction_line_id from cte_defectives
  UNION
    select transaction_line_id  from cte_cs
  union 
    select transaction_line_id  from cte_rl 
  union 
     select transaction_line_id  from cte_pl
  )
  )

select 
  t.channel,
  t.posting_period,
  t.item_id_ns,
  p.sku,
  p.display_name,
  sum(net_amount) as cogs
from cte_combined_ids ids
left join fact.gl_transaction t on ids.transaction_line_id = t.transaction_line_id
  left join dim.product p on p.item_id_ns = t.item_id_ns
where t.posting_flag
  and t.posting_period like '%24'
group by all