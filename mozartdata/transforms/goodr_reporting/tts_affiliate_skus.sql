WITH
  tts_orders AS (
    SELECT
      *
    FROM
      shopify."ORDER" so
    WHERE
      source_name = '4214587393' --- from tts 
  )
,  affilate_orders AS (
    SELECT
      order_id_edw
    FROM
      fact.orders o
      INNER JOIN tts_orders tts ON tts.name = o.order_id_ns
    WHERE
      channel = 'Marketing' --- tts source + marketing channel = tts affilate order
    group by all
  )
, sku_cost as (
  SELECT
  oid.product_id_edw,
  oid.plain_name,
  avg(oid.amount_cogs) as cost
FROM
  fact.order_item_detail oid
  INNER JOIN affilate_orders ao ON ao.order_id_edw = oid.order_id_edw
WHERE
  record_type = 'itemfulfillment'
  GROUP BY
  ALL
order by plain_name
)
SELECT
--  oid.*
  oid.product_id_edw as product_id,
  oid.plain_name,
  date_trunc(MONTH, oid.transaction_date) as month,
  sum(oid.total_quantity) as quantity,
  cost as avg_cost
FROM
  fact.order_item_detail oid
  INNER JOIN affilate_orders ao ON ao.order_id_edw = oid.order_id_edw
  inner join sku_cost on sku_cost.product_id_edw = oid.product_id_edw
WHERE
  record_type = 'itemfulfillment'
  GROUP BY
  ALL
order by month desc, plain_name