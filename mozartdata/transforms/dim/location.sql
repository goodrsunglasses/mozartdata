SELECT
  id location_id_ns,
  name as name,
  fullname as full_name,
  case when usebins = 'T' then true else false end use_bins_flag,
  case when makeinventoryavailable = 'T' then true else false end make_inventory_available_flag,
  case when makeinventoryavailablestore = 'T' then true else false end make_inventory_available_store_flag,
  case when isinactive = 'F' then true else false end active_flag
FROM
  netsuite.location