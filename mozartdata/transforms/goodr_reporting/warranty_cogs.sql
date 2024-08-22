--- get ids for orders that hit 4220
WITH
  defective_ids AS (
    SELECT
      order_id_ns
    FROM
      fact.gl_transaction
    WHERE
      account_number = 4220
  ),

--- get cogs for orders that hit 4220  
  cte_defectives AS (
    SELECT
      gl.order_id_edw,
      gl.order_id_ns AS returnlogic_order_id_ns,
      gl.transaction_number_ns,
      gl.transaction_line_id,
      gl.channel,
      gl.transaction_date,
      gl.posting_period,
      gl.net_amount AS cogs,
      p.display_name,
      p.sku
    FROM
      fact.gl_transaction gl
      LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
      INNER JOIN defective_ids id ON id.order_id_ns = gl.order_id_ns
    WHERE
      gl.account_number = 5000
      AND posting_flag
      AND posting_period LIKE '%2024'
  )

--- get the cogs for CS orders that have warrenty prefixes per the CS ORDER NUMBERS deck (less is_exchange true)
, 
  cte_cs AS (
    SELECT DISTINCT
      gl.order_id_edw,
      gl.order_id_ns AS cs_order_id_ns,
      gl.transaction_number_ns,
      gl.transaction_line_id,
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
        OR gl.order_id_ns ILIKE 'CS-DMG%'
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
      o.is_exchange
  ),
  --- CTE for COGS of returnlogic warranties, excluding orders already in cte_cs
  cte_rl AS (
    SELECT DISTINCT
      gl.order_id_edw,
      gl.order_id_ns AS returnlogic_order_id_ns,
      gl.transaction_number_ns,
      gl.transaction_line_id,
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
  --- CTE for COGS of shopify warranties, excluding orders already in cte_cs or cte_rl
  cte_pl AS (
    SELECT DISTINCT
      gl.order_id_edw,
      gl.order_id_ns AS shopify_order_id_ns,
      gl.transaction_number_ns,
      gl.transaction_line_id,
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
  
  --- get unique ids
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
--- get final cogs
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