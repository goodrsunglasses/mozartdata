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
  ful.order_id_edw,
  ful.ship_date AS ship_date_stord_api,
  COALESCE(o.channel, 
  CASE
  WHEN left(ful.order_id_edw, 3) = 'GCA' THEN 'goodr.ca'
  WHEN left(ful.order_id_edw, 3) = 'G-C' THEN 'goodr.ca'
  WHEN left(ful.order_id_edw, 4) = 'SG-C' THEN 'sellgoodr ca'
  when ful.order_id_edw ilike 'CS%' then 'customer service'  ---- but have to update to canada when unfilter for canada 
  when ful.order_id_edw like '%SG-CA%' then 'sellgoodr ca'
  WHEN left(ful.order_id_edw, 3) = 'GW-' THEN 'goodrwill'
  WHEN left(ful.order_id_edw, 3) = 'CAB' THEN 'cabana'
  WHEN left(ful.order_id_edw, 2) = 'SG' THEN 'sellgoodr'
  WHEN left(ful.order_id_edw, 1) = 'G' THEN 'goodr.com'
  WHEN left(ful.order_id_edw, 2) = 'TO' THEN 'transfer order'
  WHEN left(ful.order_id_edw, 2) = 'CS' THEN 'customer service'
  WHEN left(ful.order_id_edw, 3) = 'SD-' THEN 'marketing'
  WHEN left(ful.order_id_edw, 3) = 'PR-' THEN 'marketing'
  WHEN left(ful.order_id_edw, 3) = 'SIG' THEN 'marketing'
  WHEN left(ful.order_id_edw, 3) = 'BRA' THEN 'sellgoodr'
  WHEN left(ful.order_id_edw, 3) = 'POP' THEN 'pop'  -- seperated bc idk if these are sellgoodr or sellgoodr ca and they are very different parcel costs anyways
  ELSE 'other'
  END  ) as channel
  
FROM
  stord_invoices.parcel_details p
  LEFT JOIN ful ON p.shipment_tracking_number = ful.tracking_number
  LEFT JOIN fact.orders o ON ful.order_id_edw = o.order_id_edw
  --WHERE
  --  detailed_carrier LIKE 'As%'  -- canada 
  --  and order_id_edw is null  --- qc (85 rows) and
  --  channel_guess = 'other'  --- qc (89 rows, same as above)
  )
--select distinct channel from core  --- qc
--select distinct detailed_carrier from core where channel is null
--select count(*) from core where channel is null
--select count (*) from core where detailed_carrier ilike 'Ase%'
select * from core
--  where channel = 'other' and order_number_wms is  null order by order_number_wms
--select * from core where channel is null