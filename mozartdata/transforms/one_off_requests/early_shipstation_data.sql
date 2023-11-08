SELECT
  ordernumber,
  shipments.shipto:STATE::STRING AS state,
  shipments.shipdate
FROM
  shipstation_portable.shipstation_shipments_8589936627 shipments 

WHERE
  shipments.shipdate BETWEEN '2018-10-01T00:00:00' AND '2019-06-30T00:00:00'
and state = 'IL'