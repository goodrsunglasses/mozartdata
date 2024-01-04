SELECT
  o.order_id_edw
, o.booked_date
, o.sold_date
, o.fulfillment_date
, o.amount_sold
FROM
  fact.orders o
WHERE
   date_trunc(month,date(o.sold_date)) = '2023-12-01'
and (date_trunc(month,date(o.fulfillment_date)) is null or date_trunc(month,date(o.fulfillment_date)) = '2024-01-01')