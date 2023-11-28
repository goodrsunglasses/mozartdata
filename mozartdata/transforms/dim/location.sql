SELECT
  l.id location_id_ns,
  l.name as name,
  l.fullname as full_name,
  case when l.usebins = 'T' then true else false end use_bins_flag,
  case when l.makeinventoryavailable = 'T' then true else false end make_inventory_available_flag,
  case when l.makeinventoryavailablestore = 'T' then true else false end make_inventory_available_store_flag,
  case when l.isinactive = 'F' then true else false end active_flag,
  case 
  when l.name like 'HQ DC%' then 'HQ DC'
  when l.name = 'HQ DC - REI - DO NOT USE' then 'HQ DC - REI'
  when l.name like 'Stord ATL%' then 'ATL'
  when l.name like 'Stord LAS%' then 'LAS'
  else l.name
  end physical_location,
  lt.name as location_type,
  la.addr1 as address,
  la.addr2 as address_2,
  la.city as city,
  la.state,
  la.country,
  la.zip
FROM
  netsuite.location l
left join
  netsuite.locationtype lt
  on l.locationtype = lt.id
left join
  netsuite.locationmainaddress la
  on l.mainaddress = la.nkey