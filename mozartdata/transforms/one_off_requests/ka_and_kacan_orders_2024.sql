SELECT DISTINCT
  order_id_ns,
  channel,
  booked_date,
  sold_date,
  customer_id_ns,
  customer_name
FROM
  fact.orders o
  left join fact.customer_ns_map m on m.customer_id_edw = o.customer_id_edw
WHERE
  (channel = 'Key Account' or channel = 'Key Account CAN')
  AND (booked_date LIKE '2024%'
  OR sold_date LIKE '2024%')