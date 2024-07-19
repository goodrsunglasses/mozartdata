SELECT
  t.account_number,
  t.budget_category,
  t.posting_period,
  t.channel,
  sum(t.net_amount) as revenue,
  p.sku,
  p.display_name,
  p.collection,
  p.merchandise_class,
  p.merchandise_department,
  p.merchandise_division,
  p.family,
  p.stage
FROM
  fact.gl_transaction t
  LEFT JOIN dim.product p ON t.item_id_ns = p.item_id_ns
WHERE
  t.account_number like '4%'
  and t.posting_period like '%2024'
  and posting_flag 
group by 
  t.account_number,
  t.budget_category,
  t.posting_period,
  t.channel,
  p.sku,
  p.display_name,
  p.collection,
  p.merchandise_class,
  p.merchandise_department,
  p.merchandise_division,
  p.family,
  p.stage