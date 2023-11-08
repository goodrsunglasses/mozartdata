SELECT
  orders.ordernumber,
  shipments.shipto:STATE::STRING AS state,
  orders.amountpaid,
  shipments.shipdate
FROM
  shipstation_portable.shipstation_shipments_8589936627 shipments 
  left outer join shipstation_portable.shipstation_orders_8589936627 orders on orders.orderid = shipments.orderid
WHERE
  shipments.shipdate BETWEEN '2018-10-01T00:00:00' AND '2019-06-30T00:00:00'
and state = 'IL'