SELECT
  fulfillment_id_edw,
  carriercode,
  createdate,
  shipdate,
  customeremail,
  ordernumber,
  servicecode,
  shipmentcost,
  voided,
  shipto:CITY::STRING AS city,
  shipto:COUNTRY::STRING AS country,
  shipto:STATE::STRING AS state

FROM
  dim.fulfillment fulfill
  LEFT OUTER JOIN shipstation_portable.shipstation_shipments_8589936627 shipstation ON TO_CHAR(shipstation.shipmentid) = fulfill.source_system_id
WHERE
  source_system = 'Shipstation'
  --Stord
  UNION ALL
  SELECT
    fulfillment_id_edw
  FROM
    dim.fulfillment fulfill
  WHERE
    source_system = 'Stord'