with periods as
  (
    select 'year' as period_type,'Jan ''22-Dec ''22' as period, '2022-01-01' as period_date union all
    select 'year' as period_type,'Jan ''23-Dec ''23' as period, '2023-01-01' as period_date union all
    select 'month' as period_type,'Jun ''23' as period, '2023-06-01' as period_date union all
    select 'month' as period_type,'Jun ''24' as period, '2024-06-01' as period_date

  )
SELECT
  p.item_id_ns,
  p.display_name,
  p.sku,
  p.family,
  p.collection,
  p.stage,
  p.merchandise_department,
  p.merchandise_class,
  p.product_id_edw,
  case when yp.period is not null then true else false end as yearly_period_flag,
  yp.period,
  case when mp.period is not null then true else false end as monthly_period_flag,
  mp.period,
  min(po.purchase_date) AS earliest_po_date,
  max(po.purchase_date) AS latest_po_date,
  min(o.sold_date) as earliest_order_date,
  max(o.sold_date) as latest_order_date
FROM
  dim.product p
  LEFT JOIN fact.purchase_order_item poi on p.item_id_ns = poi.item_id_ns
  LEFT JOIN fact.purchase_orders po on po.order_id_edw = poi.order_id_edw
  left join fact.order_item oi on p.item_id_ns = oi.item_id_ns  --- does not take channel into account
  left join fact.orders o on o.order_id_edw = oi.order_id_edw
  left join periods yp on (yp.period_type = 'year' and (date_trunc('year',po.purchase_date) = yp.period_date or date_trunc('year',o.sold_date) = yp.period_date))
  left join periods mp on (mp.period_type = 'month' and (date_trunc('month',po.purchase_date) = mp.period_date or date_trunc('month',o.sold_date) = mp.period_date))
--WHERE p.sku = 'G00349-OG-LTG2-RF'
GROUP BY
  all