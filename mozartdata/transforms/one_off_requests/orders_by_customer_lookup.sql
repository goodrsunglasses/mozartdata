select
  customer_id_ns,
  channel, 
  booked_date,
  sold_date,
  fulfillment_date,
  quantity_sold,
  revenue,
FROM
  fact.orders o
  LEFT JOIN fact.CUSTOMER_NS_MAP cn ON o.CUSTOMER_ID_EDW = cn.CUSTOMER_ID_EDW
WHERE
  cn.CUSTOMER_ID_NS = 'CUST2'
ORDER BY
  SOLD_DATE desc