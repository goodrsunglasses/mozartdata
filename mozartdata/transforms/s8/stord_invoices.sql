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
  SELECT
  p.*,
  replace(p.order_number_wms,' ','') as order_id_edw_p,
  ful.order_id_edw,
  ful.ship_date AS ship_date_stord_api,
  COALESCE(o.channel, o2.channel) as channel_orders,
  COALESCE(o.channel, o2.channel,
  CASE
  WHEN left(replace(p.order_number_wms,' ',''), 3) = 'GCA' THEN 'goodr.ca'
  WHEN left(replace(p.order_number_wms,' ',''), 3) = 'G-C' THEN 'goodr.ca'
  WHEN left(replace(p.order_number_wms,' ',''), 4) = 'SG-C' THEN 'sellgoodr ca'
  when replace(p.order_number_wms,' ','') ilike 'CS%' then 'customer service'  ---- but have to update to canada when unfilter for canada 
  when replace(p.order_number_wms,' ','') like '%SG-CA%' then 'sellgoodr ca'
  WHEN left(replace(p.order_number_wms,' ',''), 3) = 'GW-' THEN 'goodrwill'
  WHEN left(replace(p.order_number_wms,' ',''), 3) = 'CAB' THEN 'cabana'
  WHEN left(replace(p.order_number_wms,' ',''), 2) = 'SG' THEN 'sellgoodr'
  WHEN left(replace(p.order_number_wms,' ',''), 1) = 'G' THEN 'goodr.com'
  WHEN left(replace(p.order_number_wms,' ',''), 2) = 'TO' THEN 'transfer order'
  WHEN left(replace(p.order_number_wms,' ',''), 2) = 'CS' THEN 'customer service'
  WHEN left(replace(p.order_number_wms,' ',''), 3) = 'SD-' THEN 'marketing'
  WHEN left(replace(p.order_number_wms,' ',''), 3) = 'PR-' THEN 'marketing'
  WHEN left(replace(p.order_number_wms,' ',''), 3) = 'SIG' THEN 'marketing'
  WHEN left(replace(p.order_number_wms,' ',''), 3) = 'BRA' THEN 'sellgoodr'
  WHEN left(replace(p.order_number_wms,' ',''), 4) = '#BWP' THEN 'Amazon Prime'
  WHEN left(replace(p.order_number_wms,' ',''), 3) = 'POP' THEN 'pop'  -- seperated bc idk if these are sellgoodr or sellgoodr ca and they are very different parcel costs anyways
  ELSE 'other'
  END  ) as channel_colase
  
FROM
  stord_invoices.parcel_details p
  LEFT JOIN ful ON p.shipment_tracking_number = ful.tracking_number
  LEFT JOIN fact.orders o ON upper(replace(p.order_number_wms,' ','')) = upper(o.order_id_edw)
  left join fact.orders o2 on ful.order_id_edw = o2.order_id_edw
  --WHERE
  --  detailed_carrier LIKE 'As%'  -- canada 
  --  and order_id_edw is null  --- qc (85 rows) and
  --  channel_guess = 'other'  --- qc (89 rows, same as above)
  )
------------
--select count (*) from core where channel = 'other'
--select * from  core where channel = 'other'
--select count(*)  from core where channel_colase != 'other' and channel_orders is null
select count(*) from core 
  --where channel_colase = 'other'
--select * from core where order_id_edw = 'G-CA10533'
--select * from core    where channel = 'other' and order_number_wms is not null  and detailed_carrier = 'DHL ECOMMERCE'
  /*
select detailed_carrier, count(*) from core
  where channel = 'other' and order_number_wms is not null  
    group by 1 
*/
--select * from core where channel is null