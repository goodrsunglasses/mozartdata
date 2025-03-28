with revenue as (

  SELECT
    t.product_id_edw
  , coalesce(t.channel,'Not By Channel') as channel
  , t.posting_period
  , t.order_id_edw
  , coalesce(p.sku,'Not By SKU') as sku
  , p.display_name
  , SUM(COALESCE(-tranline.quantity, 0))                                    AS quantity
  , SUM(-tranline.costestimate)                                             AS cost_est
  , SUM(t.net_amount)                                                       AS revenue
  , DIV0(SUM(t.net_amount), SUM(COALESCE(-tranline.quantity, 0)))           AS unit_rev
  , DIV0(SUM(-tranline.costestimate), SUM(COALESCE(-tranline.quantity, 0))) AS unit_cost
  , p.collection
  , p.family
  , p.stage
  , p.merchandise_class
  , p.merchandise_department
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
  AND (posting_period like '%2024' or posting_period like '%2025')
  AND (p.merchandise_department = 'SUNGLASSES' or p.merchandise_department is null)
  -- AND p.sku = 'OG-HND-NRBR1'
  -- AND posting_period = 'Aug 2024'
  GROUP BY ALL
  )
, cogs as
       (
  SELECT
    t.product_id_edw
  , coalesce(t.channel,'Not By Channel') as channel
  , r.posting_period
  , t.order_id_edw
  , SUM(COALESCE(tranline.quantity, 0))                                    AS quantity
  , SUM(tranline.costestimate)                                             AS cost_est
  , SUM(t.net_amount)                                                       AS cogs
  , DIV0(SUM(t.net_amount), SUM(COALESCE(-tranline.quantity, 0)))           AS unit_cogs
  , DIV0(SUM(-tranline.costestimate), SUM(COALESCE(-tranline.quantity, 0))) AS unit_cost
  FROM
    fact.gl_transaction t
     inner join
       revenue r
       using(order_id_edw, product_id_edw)
    LEFT JOIN
      netsuite.transactionline tranline
      ON tranline.transaction = t.transaction_id_ns
      AND tranline.id = t.transaction_line_id_ns
      AND tranline.item = t.item_id_ns
      AND tranline.mainline = 'F'
      AND (
            account_number = 5000 and (tranline.accountinglinetype in ('COGS','CUSTOMERRETURNVARIANCE','DROPSHIPEXPENSE') AND tranline.iscogs = 'T')
            OR tranline.accountinglinetype in ('DROPSHIPEXPENSE')
          )
      AND (tranline._FIVETRAN_DELETED = false or tranline._FIVETRAN_DELETED is null)
    LEFT JOIN dim.product p USING (product_id_edw)
  WHERE
      posting_flag
  AND account_number = 5000
  GROUP BY ALL
         )
, amazon as
  (
    select
      gt.posting_period
    , gt.account_number
    , coalesce(gt.channel,'Not By Channel') as channel
    , gt.order_id_edw
    , 'Not By SKU' as sku
    , coalesce(sum(gt.net_amount),0) net_amount
    from
      fact.gl_transaction gt
    LEFT JOIN dim.product p USING (product_id_edw)
    where
      gt.posting_flag
    and gt.account_number in (5016,6016)
    GROUP BY ALL
  )
, amazon_orders as
  (
    select
      r.posting_period
    , r.channel
    , 'Not By SKU' as sku
    , a.account_number
    , coalesce(sum(a.net_amount),0) as net_amount
    from
      revenue r
    inner join
      amazon a
      using(order_id_edw)
    where
      a.order_id_edw is not null
    group by all
  )
, amazon_bulk as
  (
    select
      a.posting_period
    , a.channel
    , 'Not By SKU' as sku
    , a.account_number
    , coalesce(sum(a.net_amount),0) as net_amount
    from
      amazon a
    where
      a.order_id_edw is null
    group by all
  )
, bank_fees as
  (
    select
      gt.posting_period
    , coalesce(gt.channel,'Not By Channel') as channel
    , gt.order_id_edw
    , coalesce(p.sku,'Not By SKU') as sku
    , p.display_name
    , coalesce(sum(gt.net_amount),0) net_amount
    from
      fact.gl_transaction gt
    LEFT JOIN dim.product p USING (product_id_edw)
    where
      gt.posting_flag
    and gt.account_number in (5005,6005)
    and gt.channel is not null
    GROUP BY ALL
  )
, threepl as
  (
    select
      gt.posting_period
    , coalesce(gt.channel,'Not By Channel') as channel
    , gt.order_id_edw
    , coalesce(p.sku,'Not By SKU') as sku
    , p.display_name
    , coalesce(sum(gt.net_amount),0) net_amount
    from
      fact.gl_transaction gt
    LEFT JOIN dim.product p USING (product_id_edw)
    where
      gt.posting_flag
    and gt.account_number in (5015,6015)
    and gt.channel is not null
    GROUP BY ALL
  )
, shipping as
  (
    select
      gt.posting_period
    , coalesce(gt.channel,'Not By Channel') as channel
    , gt.order_id_edw
    , coalesce(p.sku,'Not By SKU') as sku
    , p.display_name
    , coalesce(sum(gt.net_amount),0) net_amount
    from
      fact.gl_transaction gt
    LEFT JOIN dim.product p USING (product_id_edw)
    where
      gt.posting_flag
    and ((gt.account_number = 5020 and posting_period like '%2025') or (gt.account_number = 6020 and posting_period like '%2024'))
    and gt.channel is not null
    GROUP BY ALL
  )
, shrinkage_inventory as
  (
    select
      gt.posting_period
    , coalesce(gt.channel,'Not By Channel') as channel
    , gt.order_id_edw
    , coalesce(p.sku,'Not By SKU') as sku
    , p.display_name
    , coalesce(sum(gt.net_amount),0) net_amount
    from
      fact.gl_transaction gt
    LEFT JOIN dim.product p USING (product_id_edw)
    where
      gt.posting_flag
    and gt.account_number = 5100
    and gt.channel is not null
    GROUP BY ALL
  )
, royalties as
  (
    select
      gt.posting_period
    , coalesce(gt.channel,'Not By Channel') as channel
    , gt.order_id_edw
    , coalesce(p.sku,'Not By SKU') as sku
    , p.display_name
    , coalesce(sum(gt.net_amount),0) net_amount
    from
      fact.gl_transaction gt
    LEFT JOIN dim.product p USING (product_id_edw)
    where
      gt.posting_flag
    and gt.account_number = 5110
    and gt.channel is not null
    GROUP BY ALL
  )
, lcv as        --- landed cost variance
  (
    select
      gt.posting_period
    , coalesce(gt.channel,'Not By Channel') as channel
    , gt.order_id_edw
    , coalesce(p.sku,'Not By SKU') as sku
    , p.display_name
    , coalesce(sum(gt.net_amount),0) net_amount
    from
      fact.gl_transaction gt
    LEFT JOIN dim.product p USING (product_id_edw)
    where
      gt.posting_flag
    and gt.account_number = 5200
    and gt.channel is not null
    GROUP BY ALL
  )
-- , variance as
-- (
--   select
--     r.sku
--   , r.posting_period
--   , r.channel
--   , sum(r.quantity) quantity_var
--   , sum(r.revenue) revenue_var
--   , count(distinct r.order_id_edw) order_count_var
--   from revenue r
--     left join
--   cogs c
--   using(order_id_edw, product_id_edw, posting_period)
--   where c.order_id_edw is null and c.product_id_edw is null and c.posting_period is null
--   group by all

-- )
SELECT
  r.sku
, coalesce( r.display_name, r.sku) as item
, r.channel
, r.posting_period
, sum(r.revenue) as revenue
, sum(r.quantity) as revenue_quantity
, div0(sum(r.revenue),sum(r.quantity)) unit_rev
, sum(c.cogs) as cogs
, sum(c.quantity) as cogs_quantity
, div0(sum(c.cogs),sum(r.quantity)) unit_cogs
, div0(sum(r.cost_est),sum(r.quantity)) as avg_cost_est_ns
--, avg(r.cost_est) as avg_cost_est_ns
-- , v.revenue_var
-- , v.quantity_var
-- , v.order_count_var
, coalesce(ab.net_amount,0) as amazon_bulk
, coalesce(ao.net_amount,0) as amazon_order
, coalesce(bank_fees.net_amount,0) as bank_fees
, coalesce(threepl.net_amount,0) as threepl
, coalesce(shipping.net_amount,0) as shipping 
, coalesce(shrinkage_inventory.net_amount,0) as shrinkage_inventory 
, coalesce(royalties.net_amount,0) as royalties
, coalesce(lcv.net_amount,0) as lcv                       -- landed cost variance 
--, coalesce(sum(c.cogs),0)+coalesce(ab.net_amount,0)+coalesce(ao.net_amount,0)+coalesce(cos.net_amount,0) as cost_of_sales
--, div0(coalesce(sum(r.revenue),0),coalesce(nullif(sum(r.quantity),0),1))
--  -div0(coalesce(sum(c.cogs),0)+coalesce(ab.net_amount,0)+coalesce(ao.net_amount,0)+coalesce(cos.net_amount,0),
--        coalesce(nullif(sum(r.quantity),0),1)) margin
, coalesce(sum(c.cogs),0)+coalesce(ab.net_amount,0)+coalesce(ao.net_amount,0)+coalesce(bank_fees.net_amount,0) +coalesce(threepl.net_amount,0) +coalesce(shipping.net_amount,0) +coalesce(shrinkage_inventory.net_amount,0) +coalesce(royalties.net_amount,0) +coalesce(lcv.net_amount,0) as cost_of_sales
, sum(r.revenue) - (sum(c.cogs)) as rev_minus_cogs
, sum(r.revenue) - (coalesce(sum(c.cogs),0)+coalesce(ab.net_amount,0)+coalesce(ao.net_amount,0)+coalesce(bank_fees.net_amount,0) +coalesce(threepl.net_amount,0) +coalesce(shipping.net_amount,0) +coalesce(shrinkage_inventory.net_amount,0) +coalesce(royalties.net_amount,0) +coalesce(lcv.net_amount,0)) as rev_minus_cos
, r.collection
, r.family
, r.stage
, r.merchandise_class
, r.merchandise_department
from
  revenue r
left join
  cogs c
  using(order_id_edw, product_id_edw, posting_period, channel)
-- left join
--   variance v
--   using(posting_period,sku,channel)
left join
  amazon_bulk ab
  using(posting_period,sku,channel)
left join
  amazon_orders ao
  using(posting_period,sku,channel)
left join
  bank_fees 
  using (posting_period,sku,channel)
left join
  threepl
  using (posting_period,sku,channel)
left join
  shipping
  using (posting_period,sku,channel)
left join
  shrinkage_inventory
  using (posting_period,sku,channel)
left join
  royalties
  using (posting_period,sku,channel)
left join
  lcv
  using (posting_period,sku,channel)
left join dim.product p using (sku)
group by all