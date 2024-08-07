SELECT
  t.account_number,
  t.budget_category,
  t.posting_period,
  t.channel,
  sum(t.net_amount) as cogs,
  sum(ol.order_line_quantity) as quantity,
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
  left join fact.order_line ol on ol.transaction_id_ns = t.transaction_id_ns
WHERE
--  t.record_type = 'itemfulfillment'
  t.account_number = 5000
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