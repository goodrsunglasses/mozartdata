SELECT
  ordernumber,
  trackingnumber fulfillment_id_edw,
  null as stord_id,
  shipmentid shipstation_id
FROM
  shipstation_portable.shipstation_shipments_8589936627 shipstation
  -- LEFT OUTER JOIN netsuite.trackingnumber
where ordernumber='G1863077'