/*
This will be used as part of year end data tasks.

We need to filter for orders that are not sold until the next year or fulfilled & sold is null. We have can have some orders which aren't "sold" because they give aways.

Update the dates below:
    year(o.booked_date) = 2024
AND o.tier IS NOT NULL
AND (o.sold_date >= '2025-01-01' OR (o.sold_date IS NULL and o.fulfillment_date is null))

*/

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
, o.sold_date
, o.amount_revenue_booked
FROM
  fact.orders o
LEFT JOIN
  fact.customer_ns_map c
on o.customer_id_edw = c.customer_id_edw
WHERE
    year(o.booked_date) = 2024
AND o.tier IS NOT NULL
AND (o.sold_date >= '2025-01-01' OR (o.sold_date IS NULL and o.fulfillment_date is null))