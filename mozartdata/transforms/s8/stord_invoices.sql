WITH
  ful AS (
    SELECT
      *
    FROM
      fact.fulfillment_item_detail fid
    WHERE
      source = 'Stord'
  )
, core as (
  SELECT distinct
  p.*,
  replace(p.order_number_wms,' ','') as order_id_edw_p,
  ful.order_id_edw,
  to_date(ful.ship_date) as ship_date_stord_api,
  COALESCE( (date_trunc(month, try_to_date(p.ship_date))),date_trunc(month, try_to_date(to_date(ful.ship_date)))) as  ship_month,
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
  stord_invoices.parcel_details p
  LEFT JOIN ful ON p.shipment_tracking_number = ful.tracking_number
  LEFT JOIN fact.orders o ON upper(replace(p.order_number_wms,' ','')) = upper(o.order_id_edw)
  left join fact.orders o2 on ful.order_id_edw = o2.order_id_edw
  )
select * from core

  ---- qc
--where channel_COALESCE  = 'key accounts' or channel_COALESCE = 'key account can'
--where channel_COALESCE  = 'other'
--select sum(TOTAL_SHIPPING_LESS_DUTIES) from core where channel_COALESCE  = 'other'