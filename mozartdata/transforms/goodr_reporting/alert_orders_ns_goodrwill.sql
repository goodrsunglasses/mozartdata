SELECT
  DISTINCT(s.name),
  s.created_at,
  o.order_id_edw as fact_orders,
  t.custbody_boomi_externalid as netsuite
FROM
  goodrwill_shopify."ORDER" s
  LEFT JOIN fact.orders o ON s.name = o.order_id_edw
  left join netsuite.transaction t on s.name = t.custbody_boomi_externalid
WHERE
  (o.order_id_edw IS NULL or t.custbody_boomi_externalid is null)
  and s.created_at > '2024-01-01'
  and s.name <> 'EMP-8010' ---didnt sync, unwanted