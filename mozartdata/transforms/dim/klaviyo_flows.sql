/*
Purpose: This table contains meta data about klaviyo flows. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Transforms: all dates are natively in UTC, so I converted them to LA time.
About this data: Klaviyo Flows are automated (or manual) email workflows which are sent to customers
(or potential customers). Examples include reminders for abandoned carts, new customer flows, reminders
for customers who haven't purchased recently. etc. Unlike campaigns, these are more evergreen and not
focused on a specific campaign
*/
SELECT
  f.created as created_timestamp
, date(f.created) as created_date
, convert_timezone('UTC', 'America/Los_Angeles', f.created) as created_timestamp_pst
, date(convert_timezone('UTC', 'America/Los_Angeles', f.created)) as created_date_pst
, f.flow_id as flow_id_klaviyo
, f.name
, f.status
, f.trigger_type
, f.archived as archive_flag
FROM 
  klaviyo_portable.klaviyo_v2_flows_8589937320 f