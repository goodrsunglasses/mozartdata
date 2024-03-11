SELECT 
  lp.list_id as list_id_klaviyo
, l.name as list_name
, lp.profile_id as profile_id_klaviyo
FROM 
  klaviyo_portable.klaviyo_v2_list_profiles_8589937320 lp
LEFT JOIN
  klaviyo_portable.klaviyo_v2_lists_8589937320 l
  on lp.list_id = l.list_id