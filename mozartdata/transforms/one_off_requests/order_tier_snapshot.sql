SELECT
  o.order_id_edw
, o.order_id_ns
, o.channel
, o.customer_id_ns
, o.customer_id_edw
, c.customer_name
, c.company_name
, c.customer_number
, o.tier
, o.booked_date
, o.fulfillment_date
, o.amount_revenue_booked
FROM
  fact.orders o
LEFT JOIN
  fact.customer_ns_map c
on o.customer_id_edw = c.customer_id_edw
WHERE
    o.booked_date <= '2024-12-31'
AND o.tier IS NOT NULL
AND (o.sold_date >= '2025-01-01' OR o.sold_date IS NULL)