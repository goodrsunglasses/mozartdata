SELECT
   _portable_extracted,
   attributes,
   id as event_id,
   links,
   relationships,
  timestamp,
  type
FROM  klaviyo_portable_v3_2.events
limit 100
