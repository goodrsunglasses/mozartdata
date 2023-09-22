--NS Events on IF's
SELECT DISTINCT
  custbody_goodr_shopify_order order_id_edw,
  tran.id fulfillment_event_id_edw,
  createddate,
  sum(CASE
          WHEN tranline.itemtype = 'InvtPart' THEN -1 * quantity
          WHEN tranline.itemtype = 'NonInvtPart'
          AND tranline.custcol2 LIKE '%GC-%' THEN -1 * quantity
          ELSE 0
        END) over (partition by order_id_edw) as quantity_listed
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
WHERE
  recordtype = 'itemfulfillment'
  AND createddate >= '2022-01-01T00:00:00Z'
-- UNION ALL
-- --Shipstation Shipment Creations
-- SELECT
--   ordernumber AS order_num,
--   shipmentid
--   createdate
-- FROM
--   shipstation_portable.shipstation_shipments_8589936627 shipments
--   where createdate >= '2022-01-01T00:00:00Z'
-- UNION ALL
--Shopify Fulfillment Events
-- SELECT
--   shop_order.name AS order_num,
--   MAX(estimated_delivery_at) OVER (
--     PARTITION BY
--       order_id
--   ) AS est_delivery,
--   happened_at,
--   message
-- FROM
--   shopify.fulfillment_event fulfill_event
--   LEFT OUTER JOIN shopify."ORDER" shop_order ON shop_order.id = fulfill_event.order_id