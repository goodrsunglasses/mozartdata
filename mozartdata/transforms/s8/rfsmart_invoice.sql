--- get the same columns (or similar) for rf smart that we've got for  stord invoices (after adding the new things)

with     not_picked_up AS (
    SELECT
      *
    FROM
      rfsmart_invoices.rfsmart_20250410 rf
    WHERE
      carriermethod <> 'Will Call / Pickup'
--      and packagetrackingnumber is null  --- 0 
  )
,   core AS (
    SELECT
      trackingnumber AS tracking_number,
      packagetrackingnumber AS package_tracking_number,
      fulfillmentnumber AS fulfillment_number,
      ol.order_id_edw,
      ol.channel,
      fromname AS location,
      carriername AS carrier_name,
      carriermethod AS carrier_method,
      createdat,
      lastmodifiedat,
      erpprocessingstartedat,
      erpprocessingfinishedat,
      inhomedate,
      tocompanyname AS to_company_name,
      toline1 AS to_line1,
      toline2 AS to_line2,
      toline3 AS to_line3,
      tocity AS to_city,
      tostateorprovince AS to_state,
--      coalesce(map.code, tostateorprovince) as to_state_code,
      map.code as to_state_code1,
      topostalcode AS to_zip,
      tocountrycode AS to_country,
      isvoided AS is_voided,
      ratetotalnetcharge AS rate_total_netcharge,
      ratecurrencycode AS rate_currency,
      LENGTH,
      width,
      height,
      sizeunits AS size_units,
      weightunits AS weight_units,
      sscc,
      case 
        when carriermethod ILIKE '%ground%' then 'standard' 
        else 'priority' end as standard_priority,
      sr.region,
      'rfsmart_20250410' as source
    FROM
      not_picked_up rf --2293
      left join fact.order_line ol on ol.transaction_number_ns = rf.fulfillmentnumber and ol.tracking_number = rf.packagetrackingnumber 
        left join csvs.states_lookup map on map.state = rf.tostateorprovince
        left join dim.shipping_regions sr on sr.code = map.code
  )
SELECT
  *
FROM
  core