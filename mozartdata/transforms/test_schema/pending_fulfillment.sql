SELECT DISTINCT
  tran.custbody_goodr_shopify_order order_num,
  tran.createddate,
  shipment.shipmentid
  
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
  left outer join shipstation_portable.shipstation_shipments_8589936627 shipment on shipment.ordernumber = tran.custbody_goodr_shopify_order
WHERE
  transtatus.fullname LIKE '%Pending Fulfillment%'
and tran.recordtype = 'salesorder'
and shipmentid is not null