--- 4220 defectives 
WITH
  defective_ids AS (
    SELECT
      order_id_ns
    FROM
      fact.gl_transaction
    WHERE
      account_number = 4220
  )
,
  cte_defectives AS (
    SELECT
      gl.order_id_ns,
      gl.transaction_line_id
    FROM
      fact.gl_transaction gl
      INNER JOIN defective_ids d ON d.order_id_ns = gl.order_id_ns
    where gl.account_number = 5000
    and posting_flag
  )

---- cs orders (Ci and CS_DMG)
,  cte_cs AS (
    SELECT
      gl.order_id_ns,
      gl.transaction_line_id
    FROM
      fact.gl_transaction gl
    WHERE
      gl.account_number = 5000
      AND (
        gl.order_id_ns ILIKE 'CI%'
        OR gl.order_id_ns ILIKE 'CS-DMG%'
      )
      AND posting_flag
  )

----- returnlogic orders
 ,   cte_rma_ids AS (
    SELECT DISTINCT
      o.order_id_ns
    FROM
      fact.orders o
    WHERE
      o.is_exchange
  ),
    cte_rl AS (
    SELECT
      gl.order_id_ns,
      gl.transaction_line_id
    FROM
      fact.gl_transaction gl
      INNER JOIN cte_rma_ids ON cte_rma_ids.order_id_ns = gl.order_id_ns
    where gl.account_number = 5000
    and posting_flag
  )
  
------ parcellab + anything that came through shopify with warranty or exchange discount codes
,  cte_shopify_warranty_ids AS (
    SELECT 
      so.name
    FROM
      shopify."ORDER" so
      LEFT JOIN shopify.discount_application d ON so.id = d.order_id
    WHERE
      d.description ILIKE 'war%'
      OR d.description ILIKE 'exc%'
    UNION
    SELECT 
      so.name
    FROM
      goodr_canada_shopify."ORDER" so
      LEFT JOIN goodr_canada_shopify.discount_application d ON so.id = d.order_id
    WHERE
      d.description ILIKE 'war%'
      OR d.description ILIKE 'exc%'
  ),
    cte_pl AS (
    SELECT
      gl.order_id_ns,
      gl.transaction_line_id
    FROM
      fact.gl_transaction gl
      INNER JOIN cte_shopify_warranty_ids w ON w.name = gl.order_id_ns
    where gl.account_number = 5000
    and posting_flag
  )
----- unqiue ids and cogs 
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
  gl.channel,
  gl.posting_period,
  gl.item_id_ns,
  p.sku,
  p.display_name,
  sum(net_amount) as cogs
from cte_combined_ids ids
left join fact.gl_transaction gl on ids.transaction_line_id = gl.transaction_line_id
  left join dim.product p on p.item_id_ns = gl.item_id_ns
where gl.posting_flag
  and gl.posting_period like '%24'
group by all