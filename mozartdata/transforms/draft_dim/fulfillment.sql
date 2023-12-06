WITH
  edw_fulfillments AS (
    SELECT DISTINCT
      fulfillment_id_edw
    FROM
      (
        SELECT
          ordernumber AS order_id_edw,
          trackingnumber,
          CONCAT(order_id_edw, '_', trackingnumber) AS fulfillment_id_edw
        FROM
          shipstation_portable.shipstation_shipments_8589936627 shipstation
        UNION
        SELECT
          order_number AS order_id_edw,
          tracking_number AS trackingnumber,
          CONCAT(order_id_edw, '_', trackingnumber) AS fulfillment_id_edw
        FROM
          stord.stord_shipment_confirmations_8589936822
      )
  ),
  shipstation AS (
    SELECT
      ordernumber AS order_id_edw,
      trackingnumber,
      CONCAT(order_id_edw, '_', trackingnumber) AS fulfillment_id_edw,
      shipmentid AS shipstation_id
    FROM
      shipstation_portable.shipstation_shipments_8589936627 shipstation
  ),
  stord AS (
    SELECT
      order_number AS order_id_edw,
      tracking_number AS trackingnumber,
      CONCAT(order_id_edw, '_', trackingnumber) AS fulfillment_id_edw,
      shipment_confirmation_id AS stord_id
    FROM
      stord.stord_shipment_confirmations_8589936822
  )
  -- , netsuite AS ()
SELECT
  edw_fulfillments.fulfillment_id_edw,
  COALESCE(to_char(shipstation_id), stord_id) source_system_id,
  MAX(
    CASE
      WHEN shipstation_id IS NULL THEN 'Stord'
      ELSE 'Shipstation'
    END
  ) source_system
FROM
  edw_fulfillments
  LEFT OUTER JOIN shipstation ON shipstation.fulfillment_id_edw = edw_fulfillments.fulfillment_id_edw
  LEFT OUTER JOIN stord ON stord.fulfillment_id_edw = edw_fulfillments.fulfillment_id_edw
GROUP BY
  edw_fulfillments.fulfillment_id_edw,
  source_system_id