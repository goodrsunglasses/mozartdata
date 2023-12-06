WITH
  trackings AS (
    SELECT
      ordernumber,
      trackingnumber, fulfillment_id_edw,
  servicecode,
      createdate,
      shipmentid shipstation_id
    FROM
      shipstation_portable.shipstation_shipments_8589936627 shipstation
      -- LEFT OUTER JOIN netsuite.trackingnumber
  where fulfillment_id_edw = '9400111899223006804337'
  )
SELECT
  fulfillment_id_edw,
  COUNT(fulfillment_id_edw) counter
FROM
  trackings
GROUP BY
  fulfillment_id_edw
HAVING
  counter > 1