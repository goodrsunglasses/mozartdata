SELECT
  max(created_at) max_created_date
, max(updated_at) max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_campaigns_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_campaigns_8589937320
union all
SELECT
  max(created) max_created_date
, max(updated) max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_catalog_items_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_catalog_items_8589937320
union all
SELECT
  max(datetime) max_created_date
, null max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_events_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_events_8589937320
union all
SELECT
  max(created) max_created_date
, max(updated) max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_flows_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_flows_8589937320
union all
SELECT
  max(timestamp) max_created_date
, null max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_global_exclusions_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_global_exclusions_8589937320
union all
SELECT
  null max_created_date
, null max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_list_profiles_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_list_profiles_8589937320
union all
SELECT
  max(created) max_created_date
, max(updated) max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_lists_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_lists_8589937320
union all
SELECT
  max(created) max_created_date
, max(updated) max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_metrics_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_metrics_8589937320
union all
SELECT
  max(created) max_created_date
, max(updated) max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_profiles_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_profiles_8589937320
union all
SELECT
  max(created) max_created_date
, max(updated) max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_segments_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_segments_8589937320
union all
SELECT
  null max_created_date
, null max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_tags_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_tags_8589937320
union all
SELECT
  max(created) max_created_date
, max(updated) max_updated_date
, max(_portable_extracted) max_portable_extracted
, 'klaviyo_v2_templates_8589937320' as table_name
FROM
  klaviyo_portable.klaviyo_v2_templates_8589937320