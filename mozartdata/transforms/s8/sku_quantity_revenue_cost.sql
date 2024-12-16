SELECT
  oid.plain_name,
  ics.location,
  c.name AS channel,
  ap.periodname AS posting_period,
  oid.item_id_ns,
  ics.sku,
  p.family AS product_category,
  p.merchandise_class AS model,
  sum(oid.amount_revenue) AS revenue,
  sum(oid.total_quantity) AS quantity,
  ics.average_cost AS cost_per_unit,
  average_cost * quantity AS total_cost,
FROM
  fact.order_item_detail oid
  LEFT OUTER JOIN netsuite.transaction t ON t.id = oid.transaction_id_ns
  LEFT OUTER JOIN dim.channel c ON c.channel_id_ns = t.cseg7
  LEFT JOIN netsuite.accountingperiod ap ON ap.id = t.postingperiod
  LEFT JOIN s8.inventory_cost_sheet ics ON ics.item_id_ns = oid.item_id_ns
  AND ics.location_id_ns = oid.location
  LEFT JOIN dim.product p ON p.item_id_ns = oid.item_id_ns
WHERE
  oid.record_type IN ('cashsale', 'invoice')
  AND posting_period LIKE '%2024'
  and p.merchandise_department = 'SUNGLASSES'
GROUP BY
  ALL