with revenue as (

  SELECT
    t.product_id_edw
  , t.channel
  , t.posting_period
  , t.order_id_edw
  , p.sku
  , p.display_name
  , SUM(COALESCE(-tranline.quantity, 0))                                    AS quantity
  , SUM(-tranline.costestimate)                                             AS cost_est
  , SUM(t.net_amount)                                                       AS revenue
  , DIV0(SUM(t.net_amount), SUM(COALESCE(-tranline.quantity, 0)))           AS unit_rev
  , DIV0(SUM(-tranline.costestimate), SUM(COALESCE(-tranline.quantity, 0))) AS unit_cost
  FROM
    fact.gl_transaction t
    LEFT JOIN
      netsuite.transactionline tranline
      ON tranline.transaction = t.transaction_id_ns
        AND tranline.id = t.transaction_line_id_ns
        AND tranline.item = t.item_id_ns
        AND tranline.mainline = 'F'
        AND tranline.accountinglinetype = 'INCOME'
        AND (tranline._fivetran_deleted = FALSE OR tranline._fivetran_deleted IS NULL)
    LEFT JOIN dim.product p USING (product_id_edw)
  WHERE
      posting_flag
  AND account_number LIKE '4%'
  AND p.sku = 'OG-HND-NRBR1'
  AND posting_period = 'Aug 2024'
  GROUP BY ALL
  )
, cogs as
       (
  SELECT
    t.product_id_edw
  , t.channel
  , t.posting_period
  , t.order_id_edw
  , SUM(COALESCE(tranline.quantity, 0))                                    AS quantity
  , SUM(tranline.costestimate)                                             AS cost_est
  , SUM(t.net_amount)                                                       AS cogs
  , DIV0(SUM(t.net_amount), SUM(COALESCE(-tranline.quantity, 0)))           AS unit_cogs
  , DIV0(SUM(-tranline.costestimate), SUM(COALESCE(-tranline.quantity, 0))) AS unit_cost_est
  FROM
    fact.gl_transaction t
--     inner join
--       revenue r
--       using(order_id_edw, product_id_edw, posting_period)
    LEFT JOIN
      netsuite.transactionline tranline
      ON tranline.transaction = t.transaction_id_ns
      AND tranline.id = t.transaction_line_id_ns
      AND tranline.item = t.item_id_ns
      AND tranline.mainline = 'F'
      AND ((tranline.accountinglinetype in ('COGS','CUSTOMERRETURNVARIANCE','DROPSHIPEXPENSE') AND tranline.iscogs = 'T')
           OR tranline.accountinglinetype in ('DROPSHIPEXPENSE'))
      AND (tranline._FIVETRAN_DELETED = false or tranline._FIVETRAN_DELETED is null)
    LEFT JOIN dim.product p USING (product_id_edw)
  WHERE
      posting_flag
  AND account_number LIKE '5000'
  GROUP BY ALL
         )
, variance as
(
  select
    r.sku
  , r.posting_period
  , r.channel
  , sum(r.quantity) quantity_var
  , sum(r.revenue) revenue_var
  , count(distinct r.order_id_edw) order_count_var
  from revenue r
    left join
  cogs c
  using(order_id_edw, product_id_edw, posting_period)
  where c.order_id_edw is null and c.product_id_edw is null and c.posting_period is null
  group by all

)
SELECT
  r.sku
, r.channel
, r.posting_period
, sum(r.revenue) as revenue
, sum(r.quantity) as revenue_quantity
, div0(sum(r.revenue),sum(r.quantity)) unit_rev
, sum(c.cogs) as cogs
, sum(c.quantity) as cost_quantity
, div0(sum(c.cogs),sum(r.quantity)) unit_cogs
, r.cost_est
, v.revenue_var
, v.quantity_var
, v.order_count_var
, div0(sum(r.revenue),sum(r.quantity))-div0(sum(c.cogs),sum(r.quantity)) margin
from
  revenue r
left join
  cogs c
  using(order_id_edw, product_id_edw, channel, posting_period)
left join
  variance v
  using(posting_period,sku,channel)
group by all