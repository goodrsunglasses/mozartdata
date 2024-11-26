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
    WHEN left(order_id_edw, 1) = 'G' THEN 'goodr.com'
    ELSE 'other'
    END AS channel_guess
FROM
  stord_invoices.parcel_details p
  left join ful on p.shipment_tracking_number = ful.tracking_number
WHERE
  detailed_carrier LIKE 'As%'  -- canada 
--  and order_id_edw is null  --- qc (85 rows)
--  and channel_guess = 'other'  --- qc (89 rows, same as above)