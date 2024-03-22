select distinct
  kp.email
, kp.phone_number
, kp.created_date_pst
, kp.created_timestamp_pst
FROM
  dim.klaviyo_profiles kp
left join
  fact.klaviyo_list_profiles lp
  on kp.profile_id_klaviyo = lp.profile_id_klaviyo
WHERE
   list_id_klaviyo is null
  and email is not null
  and source = 'attentive'
order by created_date_pst desc