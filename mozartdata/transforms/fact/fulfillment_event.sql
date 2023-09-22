--NS Events on IF's
SELECT DISTINCT
  custbody_goodr_shopify_order order_id_edw,
  tran.id fulfillment_event_id_edw,
  CONVERT_TIMEZONE('America/Los_Angeles', createddate) converted_timestamp_pst,
  sum(CASE
          WHEN tranline.itemtype = 'InvtPart' THEN -1 * quantity
          WHEN tranline.itemtype = 'NonInvtPart'
          AND tranline.custcol2 LIKE '%GC-%' THEN -1 * quantity
          ELSE 0
        END) over (partition by order_id_edw,fulfillment_event_id_edw) as quantity_listed,
  'IF Created' as event_type,
  null as void_flag
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
WHERE
  recordtype = 'itemfulfillment'
  AND createddate >= '2022-01-01T00:00:00Z'
and order_id_edw = 'G1863077'

UNION ALL
--Shipstation Shipment Creations
SELECT
  ordernumber AS order_num,
  shipmentid,
  createdate,
null as quantity_listed,
  'Shipment Created' as event_type,
  voided as void_flag
FROM
  shipstation_portable.shipstation_shipments_8589936627 shipments
  where createdate >= '2022-01-01T00:00:00Z'
and order_num = 'G1863077'
order by event_type desc
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