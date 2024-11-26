WITH
  ful AS (
    SELECT
      *
    FROM
      fact.fulfillment_item_detail fid
    WHERE
      source = 'Stord'
  )

  SELECT
  p.*,
  ful.order_id_edw,
  ful.ship_date as ship_date_stord_api,
  

  CASE
    WHEN left(order_id_edw, 3) = 'GCA' THEN 'goodr.ca'
    WHEN left(order_id_edw, 3) = 'G-C' THEN 'goodr.ca'
    WHEN left(order_id_edw, 4) = 'SG-C' THEN 'sellgoodr ca'
    when order_id_edw ilike 'CS%' then 'customer service'  ---- but have to update to canada when unfilter for canada 
    when order_id_edw like '%SG-CA%' then 'sellgoodr ca'
    WHEN left(order_id_edw, 3) = 'GW-' THEN 'goodrwill'
    WHEN left(order_id_edw, 3) = 'CAB' THEN 'cabana'
    WHEN left(order_id_edw, 2) = 'SG' THEN 'sellgoodr'
    WHEN left(order_id_edw, 1) = 'G' THEN 'goodr.com'
    WHEN left(order_id_edw, 2) = 'TO' THEN 'transfer order'
    WHEN left(order_id_edw, 2) = 'CS' THEN 'customer service'
    WHEN left(order_id_edw, 3) = 'SD-' THEN 'marketing'
    WHEN left(order_id_edw, 3) = 'PR-' THEN 'marketing'
    WHEN left(order_id_edw, 3) = 'SIG' THEN 'marketing'
    WHEN left(order_id_edw, 3) = 'BRA' THEN 'sellgoodr'
    WHEN left(order_id_edw, 3) = 'POP' THEN 'pop'  -- seperated bc idk if these are sellgoodr or sellgoodr ca and they are very different parcel costs anyways
    ELSE 'other'
    END AS channel_guess
  
FROM
  stord_invoices.parcel_details p
  left join ful on p.shipment_tracking_number = ful.tracking_number
--WHERE
--  detailed_carrier LIKE 'As%'  -- canada 
--  and order_id_edw is null  --- qc (85 rows) and
 --  channel_guess = 'other'  --- qc (89 rows, same as above)