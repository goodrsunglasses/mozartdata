WITH
  ful AS (
    SELECT
      tracking_number,
        CASE
        WHEN tracking_number LIKE '420%' THEN SUBSTRING(tracking_number, 9) -- Remove "420" + next 5 digits
        ELSE tracking_number
      END AS slim_tracking_number,
      order_id_edw,
      ship_date,
      state,
      sum(quantity) as qty
    FROM
      fact.fulfillment_item_detail fid
    WHERE
      source = 'Stord'
  group by all
  )
, shipping as (
  select order_id, id, code from shopify.order_shipping_line
  union all 
  select order_id, id, code from goodr_canada_shopify.order_shipping_line
  union all 
  select order_id, id, code from specialty_shopify.order_shipping_line
  union all 
  select order_id, id, code from sellgoodr_canada_shopify.order_shipping_line
)
, core as (
  SELECT distinct
  p.*,
  COALESCE(ful2.tracking_number, ful1.tracking_number) as api_tracking_number,
  ful1.slim_tracking_number as cut_tracking_number,
  COALESCE(ful2.qty, ful1.qty) as api_qty,
  replace(p.order_number_wms,' ','') as inv_order_id_edw,
  coalesce(ful2.order_id_edw,ful1.order_id_edw) as api_order_id_edw,
  COALESCE(ful2.order_id_edw,ful1.order_id_edw, replace(p.order_number_wms,' ','') ) as order_id_edw_coalesce,
  (o.amount_revenue_sold - o.amount_shipping_sold) as subtotal,       ---- by order, so will be duplicated for split shipments
  o.amount_shipping_sold as shipping_income,                          ---- by order, so will be duplicated for split shipment
  COALESCE(ful2.state, ful1.state) as state_ful,
  sr.region as shipping_region,
  coalesce(to_date(ful2.ship_date),to_date(ful1.ship_date)) as api_ship_date,
  COALESCE( (date_trunc(month, try_to_date(p.ship_date))),date_trunc(month, try_to_date(to_date(ful2.ship_date))),date_trunc(month, try_to_date(to_date(ful1.ship_date)))) as  ship_month,
  COALESCE(o.channel, o2.channel) as channel_orders,
  COALESCE(
  case 
    when  left(replace(p.order_number_wms,' ',''), 3) = 'POP' THEN 'pop'   -- seperated bc idk if these are sellgoodr or sellgoodr ca and they are very different parcel costs anyways
    when order_number_wms in ('PO-MARATHONSPORTS-030424','OSCW 26601','SG-90006','SG-103733') THEN 'specialty' end,
  lower(o.channel), lower(o2.channel),
  CASE
    WHEN left(replace(p.order_number_wms,' ',''), 3) = 'GCA' THEN 'goodr.ca'
    WHEN left(replace(p.order_number_wms,' ',''), 3) = 'G-C' THEN 'goodr.ca'
    WHEN left(replace(p.order_number_wms,' ',''), 4) = 'SG-C' THEN 'specialty can'
    when replace(p.order_number_wms,' ','') ilike 'CS%' then 'customer service'  ---- but have to update to canada when unfilter for canada 
    when replace(p.order_number_wms,' ','') like '%SG-CA%' then 'specialty can'
    WHEN left(replace(p.order_number_wms,' ',''), 3) = 'GW-' THEN 'goodrwill'
    WHEN left(replace(p.order_number_wms,' ',''), 3) = 'CAB' THEN 'cabana'
    WHEN left(replace(p.order_number_wms,' ',''), 2) = 'SG' THEN 'specialty'
    WHEN left(replace(p.order_number_wms,' ',''), 1) = 'G' THEN 'goodr.com'
    WHEN left(replace(p.order_number_wms,' ',''), 2) = 'TO' THEN 'transfer order'
    WHEN left(replace(p.order_number_wms,' ',''), 2) = 'CS' THEN 'customer service'
    WHEN left(replace(p.order_number_wms,' ',''), 3) = 'SD-' THEN 'marketing'
    WHEN left(replace(p.order_number_wms,' ',''), 3) = 'PR-' THEN 'marketing'
    WHEN left(replace(p.order_number_wms,' ',''), 3) = 'SIG' THEN 'marketing'
    WHEN left(replace(p.order_number_wms,' ',''), 3) = 'BRA' THEN 'specialty'
    WHEN left(replace(p.order_number_wms,' ',''), 4) = '#BWP' THEN 'amazon prime'
    ELSE 'other'
  END  ) as channel_COALESCE
  
FROM
  staging.stord_invoices p
  LEFT JOIN ful as ful1 ON p.shipment_tracking_number = ful1.slim_tracking_number --- count of qty is null alone was 952,455
  left join ful as ful2 ON p.shipment_tracking_number = ful2.tracking_number ---- count of qty is null with both 29,375
  LEFT JOIN fact.orders o ON upper(replace(p.order_number_wms,' ','')) = upper(o.order_id_edw)
  left join fact.orders o2 on ful2.order_id_edw = o2.order_id_edw
  left join dim.shipping_regions sr on sr.code = ful1.state   ---- check that this works for ful2 as well
  )
SELECT
  core.*,
  so.order_id_shopify,   --- bring back after qc
  ship.id,
  ship.code,
  case 
      when code ilike '%Standard%' then 'standard'  
      when code ilike '%Priority%' then 'priority'
      when code ilike '%Express%' then 'priority'
      when code ilike '%Alaska/Hawaii/Territories (5-10 Business Days)%' then 'standard' 
      when code ilike 'Alaska/Hawaii/Territories 2-8 days' then 'priority'
      when code ilike 'Alaska/Hawaii/Territories 1 business day' then 'standard'
      when code ilike '%Starbucks%' then 'standard'
      when code ilike '%Expédition%' then 'priority'
      when code ilike 'Canada (5-8 Business Days)' then 'standard'
      else 'unknown' end as standard_priority,
  case 
      when subtotal >= 50 and channel_COALESCE = 'goodr.com' then 'Above FST'
      when subtotal < 50 and channel_COALESCE = 'goodr.com' then 'Below FST'
      when subtotal >= 55.78 and channel_COALESCE = 'goodr.ca' then 'Above FST'
      when subtotal < 55.78 and channel_COALESCE = 'goodr.ca' then 'Below FST'
      when subtotal >= 1200 and channel_COALESCE = 'specialty' then 'Above FST'
      when subtotal < 1200 and channel_COALESCE = 'specialty' then 'Below FST'
      else 'No FST' end as free_ship_threshold
FROM
  core
  LEFT JOIN fact.shopify_orders so ON so.order_id_edw = core.order_id_edw_coalesce     --  will this splay? I had it as inner join before - no
  LEFT JOIN shipping ship ON so.order_id_shopify = ship.order_id                       --  will this splay?? no
--where ship_date between '2024-06-01' and '2024-10-31'                                  -- to limit for analysis per greg 
order by ship_date desc 

  ---- qc
--where channel_COALESCE  = 'key accounts' or channel_COALESCE = 'key account can'
--where channel_COALESCE  = 'other'
--select sum(TOTAL_SHIPPING_LESS_DUTIES) from core where channel_COALESCE  = 'other'


---- need to add shopify (subtotal, delivery method, shipping income)