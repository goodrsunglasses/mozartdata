--- avg parcel cost per order by channel (and avg parcel cost per unit by channel for flamingos costing project) 
-- shipstation_portable.shipstation_shipment_items_8589936627

------------ first pass 
-- with parcel_costs as (
-- SELECT 
--   DATE_TRUNC(month, ss.shipdate)::DATE AS month,
--   ss.ordernumber,
--   ss.servicecode,
--   ss.shipmentcost,
--   ss.shipmentitems,
--   SUM(f.value:QUANTITY::NUMBER) AS total_quantity
-- FROM shipstation_portable.shipstation_shipment_items_8589936627 ss,
--     LATERAL FLATTEN(input => ss.shipmentitems) f
-- GROUP BY all 
--   )
-- select 
--   pc.*,
--   so.store
-- from parcel_costs pc 
--   left join fact.shopify_orders so on so.order_id_edw = pc.ordernumber 


----------  core is the real code 
/*
with core as (
SELECT
  fl.*,
  ss.shipmentcost,
  so.store
FROM
  fact.fulfillment_line fl     --- 2,313,011
  left outer join shipstation_portable.shipstation_shipments_8589936627 ss on ss.shipmentid = fl.shipment_id    --- 2,313,011
  left join fact.shopify_orders so on so.order_id_edw = ss.ordernumber   --- 2,324,494
where source = 'Shipstation'
  )
SELECT 
  shipment_id,
  COUNT(DISTINCT store) AS store_count
FROM 
  core
GROUP BY 
  shipment_id
HAVING 
  COUNT(DISTINCT store) > 1
  */


---------- chatgpt qc for splay 
-- WITH core AS (
--   SELECT
--     TO_VARCHAR(ss.shipmentid) AS ss_shipmentid,
--     ss.shipmentcost,
--     so.store,
--     fl.shipment_id,  -- only select this if you need it
--     fl.source
--   FROM
--     fact.fulfillment_line fl
--     LEFT OUTER JOIN shipstation_portable.shipstation_shipments_8589936627 ss 
--       ON TO_VARCHAR(ss.shipmentid) = TO_VARCHAR(fl.shipment_id)
--     LEFT JOIN fact.shopify_orders so 
--       ON so.order_id_edw = ss.ordernumber
--   WHERE 
--     fl.source = 'Shipstation'
-- )
-- , dups as (
--   SELECT 
--   ss_shipmentid,
--   COUNT(DISTINCT store) AS store_count
-- FROM 
--   core
-- GROUP BY 
--   ss_shipmentid
-- HAVING 
--   COUNT(DISTINCT store) > 1
-- order by 2 desc ----- all 2 
--   )
-- select count (*) from dups 


------------ more  chatgpt qc for splay 
-- WITH core AS (
--   SELECT
--     fl.*,
--     TO_VARCHAR(ss.shipmentid) AS ss_shipmentid,
--     ss.shipmentcost,
--     so.store
--   FROM
--     fact.fulfillment_line fl
--     LEFT OUTER JOIN shipstation_portable.shipstation_shipments_8589936627 ss 
--       ON TO_VARCHAR(ss.shipmentid) = TO_VARCHAR(fl.shipment_id)
--     LEFT JOIN fact.shopify_orders so 
--       ON so.order_id_edw = ss.ordernumber
--   WHERE 
--     fl.source = 'Shipstation'
-- ),

-- multi_store_ids AS (
--   SELECT
--     ss_shipmentid
--   FROM
--     core
--   GROUP BY
--     ss_shipmentid
--   HAVING
--     COUNT(DISTINCT store) > 1
-- )

-- , more as (
--   SELECT
--   core.*
-- FROM
--   core
--   INNER JOIN multi_store_ids ON core.ss_shipmentid = multi_store_ids.ss_shipmentid
-- ORDER BY
--   ss_shipmentid, store
--   )
-- select distinct store, total_quantity from more
-- order by 2 desc 

------------ splay should be fixed based on 
  
WITH core AS (
  SELECT
    fl.shipment_id,  
    fl.total_quantity,  
    fl.source,  
    date_trunc(month, fl.ship_date) ::DATE AS ship_month,
    fl.order_id_edw,
    fl.carrier,
    fl.carrier_service,
--    fl.some_other_column,  -- Include other necessary columns here
    TO_VARCHAR(ss.shipmentid) AS ss_shipmentid,
    ss.shipmentcost,
    so.store
  FROM
    fact.fulfillment_line fl
    LEFT OUTER JOIN shipstation_portable.shipstation_shipments_8589936627 ss 
      ON TO_VARCHAR(ss.shipmentid) = TO_VARCHAR(fl.shipment_id)
    LEFT JOIN fact.shopify_orders so 
      ON so.order_id_edw = ss.ordernumber
      and lower(so.email) = lower(ss.customeremail)
  WHERE 
    fl.source = 'Shipstation'
    and fl.voided <> 'true'
),

ranked AS (
  SELECT
    core.shipment_id,
    core.total_quantity,
    core.source,
    core.ship_month,
    core.order_id_edw,
    core.carrier,
    core.carrier_service,
    core.ss_shipmentid,
    core.shipmentcost,
    core.store,
    CASE 
      WHEN core.total_quantity > 10 THEN 
        CASE WHEN core.store = 'Specialty' THEN 1 ELSE 2 END
      ELSE 
        CASE WHEN core.store = 'Goodr.com' THEN 1 ELSE 2 END
    END AS store_priority
  FROM core
),

deduped AS (
  SELECT *
  FROM ranked
  QUALIFY ROW_NUMBER() OVER (PARTITION BY ss_shipmentid ORDER BY store_priority) = 1
)

--SELECT count(*)  -- 2289536
--select * from deduped where store = 'Goodr.com' and total_quantity > 10
--select * from deduped


select 
    *, shipmentcost / total_quantity as per_unit_parcel   --- qc 
  -- date_trunc(year, ship_month),
  -- count(distinct order_id_edw) as unique_order_count,
  -- sum(total_quantity) as unit_quantity,
  -- sum(shipmentcost) as total_cost,
  -- round(sum(shipmentcost) / sum(total_quantity),2) as cost_per_unit
FROM deduped
  where store = 'Goodr.com'
  and  carrier_service not ilike '%international%'
  and carrier_service not ilike '%worldwid%'
  and carrier_service not in ('usps_priority_mail', 'usps_first_class_mail', 'usps_priority_mail_express', 'ups_2nd_day_air', 'ups_3_day_select', 'ups_next_day_air', 'dhl_gm_parcel_expedited', 'dhl_gm_parcel_ground', 'ups_worldwide_expedited', 'ups_worldwide_express', 'ups_next_day_air_saver', 'ups_worldwide_saver', 'ups_next_day_air_early_am')
--  and total_quantity > 0
--  and per_unit_parcel > 30 
  group by all 
order by per_unit_parcel