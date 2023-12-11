--NS Events on IF's
SELECT DISTINCT
  custbody_goodr_shopify_order order_id_edw,
  'Netsuite' AS source,
  tran.id fulfillment_id,
  custbody_shipment_id AS shipment_id,--Felt like adding it in on this level
  CONVERT_TIMEZONE('America/Los_Angeles', createddate) converted_timestamp_pst,
  -- SUM(
  --   CASE
  --     WHEN tranline.itemtype = 'InvtPart' THEN -1 * quantity
  --     WHEN tranline.itemtype = 'NonInvtPart'
  --     AND tranline.custcol2 LIKE '%GC-%' THEN -1 * quantity
  --     ELSE 0
  --   END
  -- ) over (
  --   PARTITION BY
  --     order_id_edw,
  --     fulfillment_id
  -- ) AS quantity_listed,
  'IF Created' AS event_details,
  NULL AS void_flag
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = tran.custbody_goodr_shopify_order
WHERE
  recordtype = 'itemfulfillment'
  AND createddate >= '2022-01-01T00:00:00Z'
  AND order_id_edw = 'G1546499'
UNION ALL
--Shipstation Shipment Creations
SELECT
  ordernumber AS order_id_edw,
  'Shipstation' AS source,
  shipmentid,
  NULL AS shipment_id,
  createdate,
  'Shipment Created' AS event_type,
  voided AS void_flag
FROM
  shipstation_portable.shipstation_shipments_8589936627 shipments
  LEFT OUTER JOIN fact.orders orders ON orders.order_id_edw = shipments.ordernumber
WHERE
  createdate >= '2022-01-01T00:00:00Z'
  AND order_id_edw = 'G1546499'
UNION ALL
--Shopify Fulfillment Events
SELECT DISTINCT
  shop_order.name AS order_id_edw,
  'Goodr.com Shopify' AS source,
  fulfill_event.fulfillment_id,
  NULL AS shipment_id,
  CONVERT_TIMEZONE('America/Los_Angeles', happened_at) converted_timestamp_pst,
  message AS event_type,
  null as void_flag
FROM
  shopify.fulfillment_event fulfill_event
  LEFT OUTER JOIN shopify."ORDER" shop_order ON shop_order.id = fulfill_event.order_id
WHERE
  order_id_edw = 'G1546499'
ORDER BY
  converted_timestamp_pst,source desc