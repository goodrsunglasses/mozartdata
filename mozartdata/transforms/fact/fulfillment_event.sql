--NS Events on IF's
SELECT DISTINCT
  custbody_goodr_shopify_order order_id_edw,
  tran.id fulfillment_event_id_edw,
  CONVERT_TIMEZONE('America/Los_Angeles', createddate) converted_timestamp_pst,
  SUM(
    CASE
      WHEN tranline.itemtype = 'InvtPart' THEN -1 * quantity
      WHEN tranline.itemtype = 'NonInvtPart'
      AND tranline.custcol2 LIKE '%GC-%' THEN -1 * quantity
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      fulfillment_event_id_edw
  ) AS quantity_listed,
  'IF Created' AS event_type,
  status_flag_edw,
  NULL AS void_flag
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN dim.orders orders ON orders.order_id_edw = tran.custbody_goodr_shopify_order
WHERE
  recordtype = 'itemfulfillment'
  AND createddate >= '2022-01-01T00:00:00Z'
  AND fulfillment_event_id_edw = 'G1863077'
UNION ALL
--Shipstation Shipment Creations
SELECT
  ordernumber AS order_num,
  shipmentid,
  createdate,
  NULL AS quantity_listed,
  'Shipment Created' AS event_type,
  status_flag_edw,
  voided AS void_flag
FROM
  shipstation_portable.shipstation_shipments_8589936627 shipments
  LEFT OUTER JOIN dim.orders orders ON orders.order_id_edw = shipments.ordernumber
WHERE
  createdate >= '2022-01-01T00:00:00Z'
  AND order_num = 'G1863077'
ORDER BY
  event_type desc
UNION ALL
--Shopify Fulfillment Events
SELECT
  shop_order.name AS order_num,
  MAX(estimated_delivery_at) OVER (
    PARTITION BY
      order_id
  ) AS est_delivery,
  happened_at,
  message
FROM
  shopify.fulfillment_event fulfill_event
  LEFT OUTER JOIN shopify."ORDER" shop_order ON shop_order.id = fulfill_event.order_id
  LEFT OUTER JOIN shopify