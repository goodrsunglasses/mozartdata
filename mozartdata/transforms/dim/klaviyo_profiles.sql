/*
Purpose: This table contains meta data about Klaviyo Profiles. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Transforms: all dates are natively in UTC, so I converted them to LA time. Several of these fields (ie.
location, properties, subscription) are JSON blobs.
About this data: Klaviyo Profiles are the customers in klaviyo.
Open questions: (as of 4/20/2024) Do we use swell or loyalty at Goodr?
The fields are mostly null, is this intentional?
*/
WITH base as
(
  SELECT
    p.id as profile_id_klaviyo
  , to_timestamp(p.attributes:CREATED::INT) as created_timestamp
  , p.attributes:EMAIL::STRING as email
  , p.attributes:FIRST_NAME::STRING as first_name
  , p.attributes:LAST_NAME::STRING as last_name
  , p.attributes:TITLE::STRING as title
  , p.attributes:LOCATION:ADDRESS1::STRING as address_1
  , p.attributes:LOCATION:ADDRESS2::STRING as address_2
  , p.attributes:LOCATION:CITY::STRING as city
  , p.attributes:LOCATION:REGION::STRING as region
  , p.attributes:LOCATION:ZIP::STRING as zip_code
  , p.attributes:LOCATION:COUNTRY::STRING as country
  , p.attributes:LOCATION:TIMEZONE::STRING as timezone
  , p.attributes:LOCATION:LATITUDE::STRING as latitude
  , p.attributes:LOCATION:LONGITUDE::STRING as longitude
  , p.attributes:PHONE_NUMBER::STRING as phone_number
  , p.attributes:ORGANIZATION::STRING as company
  , to_timestamp(p.attributes:LAST_EVENT_DATE::INT) as last_event_timestamp
  , p.attributes
  , p.attributes:PROPERTIES as properties
  FROM
    klaviyo_portable_v3_parallel.klaviyo_v3_profiles_8589938396 p
)
SELECT
  b.profile_id_klaviyo
, b.created_timestamp
, date(b.created_timestamp) as created_date
, convert_timezone('UTC', 'America/Los_Angeles', b.created_timestamp) as created_timestamp_pst
, date(convert_timezone('UTC', 'America/Los_Angeles', b.created_timestamp)) as created_date_pst
, b.email
, b.first_name
, b.last_name
, b.title
, b.address_1
, b.address_2
, p.location:CITY::varchar as city
, p.location:REGION::varchar as region
, p.location:ZIP::varchar as zip_code
, p.location:COUNTRY::varchar as country
, p.location:TIMEZONE::varchar as timezone
, p.location:LATITUDE::varchar as latitude
, p.location:LONGITUDE::varchar as longitude
, p.phone_number
, p."ORGANIZATION" as company
, JSON_EXTRACT_PATH_TEXT(p.properties,'"Accepts Marketing"')::boolean as accepts_marketing_flag
, nullif(JSON_EXTRACT_PATH_TEXT(p.properties,'"Expected Date Of Next Order"'),'*n/a*')::date as expected_next_order_date
, JSON_EXTRACT_PATH_TEXT(p.properties,'"First Purchase Date"')::date as first_purchase_date
, JSON_EXTRACT_PATH_TEXT(p.properties,'"MailChimp Rating"')::integer as mailchimp_rating
, JSON_EXTRACT_PATH_TEXT(p.properties,'"loyalty_opt_in"')::boolean as loyalty_opt_in
, JSON_EXTRACT_PATH_TEXT(p.properties,'"loyalty_opt_in_date"')::date as loyalty_opt_in_date
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_has_account"')::boolean as swell_has_account
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_credit_balance"')::varchar as swell_credit_balance
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_is_affiliate"')::boolean as swell_is_affiliate
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_point_balance"')::integer as swell_point_balance
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_points_earned"')::integer as swell_points_earned
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_points_expire_at"')::varchar as swell_points_expire_at
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_referral_discount_code"')::varchar as swell_referral_discount_code
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_referral_link"')::varchar as swell_referral_link
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_vip_tier_ends_at"')::varchar as swell_vip_tier_ends_at
, JSON_EXTRACT_PATH_TEXT(p.properties,'"swell_vip_tier_name"')::varchar as swell_vip_tier_name
, JSON_EXTRACT_PATH_TEXT(p.properties,'"$source"')::varchar as source
, p.subscriptions:EMAIL:MARKETING:CONSENT::varchar as subscription_consent
, p.subscriptions:EMAIL:MARKETING:SUPPRESSIONS[0].REASON::varchar as supression_reason
, p.subscriptions:EMAIL:MARKETING:SUPPRESSIONS[0].TIMESTAMP::datetime as suppression_timestamp
, date(p.subscriptions:EMAIL:MARKETING:SUPPRESSIONS[0].TIMESTAMP::datetime) as suppression_date
, convert_timezone('UTC','America/Los_Angeles',p.subscriptions:EMAIL:MARKETING:SUPPRESSIONS[0].TIMESTAMP::datetime) as suppression_timestamp_pst
, date(convert_timezone('UTC','America/Los_Angeles',date(p.subscriptions:EMAIL:MARKETING:SUPPRESSIONS[0].TIMESTAMP::datetime))) as suppression_date_pst
, case when p.subscriptions:EMAIL:MARKETING:SUPPRESSIONS[0].REASON::varchar is not null then true else false end supression_flag
, case when p.subscriptions:EMAIL:MARKETING:METHOD::varchar = 'EMAIL_UNSUBSCRIBE' then p.subscriptions:EMAIL:MARKETING:TIMESTAMP::datetime end as unsubscribe_timestamp
, case when p.subscriptions:EMAIL:MARKETING:METHOD::varchar = 'EMAIL_UNSUBSCRIBE' then date(p.subscriptions:EMAIL:MARKETING:TIMESTAMP::datetime) end as unsubscribe_date
, case when p.subscriptions:EMAIL:MARKETING:METHOD::varchar = 'EMAIL_UNSUBSCRIBE' then convert_timezone(p.location:TIMEZONE::varchar,'America/Los_Angeles',p.subscriptions:EMAIL:MARKETING:TIMESTAMP::datetime) end as unsubscribe_timestamp_pst
, case when p.subscriptions:EMAIL:MARKETING:METHOD::varchar = 'EMAIL_UNSUBSCRIBE' then date(convert_timezone(p.location:TIMEZONE::varchar,'America/Los_Angeles',p.subscriptions:EMAIL:MARKETING:TIMESTAMP::datetime)) end as unsubscribe_date_pst
, case when p.subscriptions:EMAIL:MARKETING:METHOD::varchar = 'SPAM_COMPLAINT' then p.subscriptions:EMAIL:MARKETING:TIMESTAMP::datetime end as spam_complaint_timestamp
, case when p.subscriptions:EMAIL:MARKETING:METHOD::varchar = 'SPAM_COMPLAINT' then date(p.subscriptions:EMAIL:MARKETING:TIMESTAMP::datetime) end as spam_complaint_date
, p.subscriptions:EMAIL:MARKETING:CUSTOM_METHOD_DETAIL::varchar as subscription_custom_method_detail
, p.subscriptions:EMAIL:MARKETING:DOUBLE_OPTIN::boolean as subscription_double_opt_in_flag
  -- , p.subscriptions:EMAIL:MARKETING:SUPPRESSIONS::varchar as subscription_suppression
-- , p.subscriptions:EMAIL:MARKETING:SUPPRESSIONS:REASON::varchar as subscription_suppression_reason
-- , p.subscriptions:EMAIL:MARKETING:SUPPRESSIONS:TIMESTAMP::datetime as subscription_suppression_timestamp
, p.subscriptions:EMAIL:MARKETING:LIST_SUPPRESSIONS::varchar as subscription_suppressions_list 
, p.subscriptions:EMAIL:MARKETING:METHOD::varchar as subscription_method
, p.subscriptions:EMAIL:MARKETING:METHOD_DETAIL::varchar as subscription_method_detail
, JSON_EXTRACT_PATH_TEXT(p.properties,'"$consent_timestamp"')::datetime as subscription_timestamp
, date(JSON_EXTRACT_PATH_TEXT(p.properties,'"$consent_timestamp"')::datetime) as subscription_date
, convert_timezone('UTC','America/Los_Angeles',JSON_EXTRACT_PATH_TEXT(p.properties,'"$consent_timestamp"')::datetime) as subscription_timestamp_pst
, date(convert_timezone('UTC','America/Los_Angeles',JSON_EXTRACT_PATH_TEXT(p.properties,'"$consent_timestamp"')::datetime)) as subscription_date_pst
, p.updated as updated_timestamp
, date(p.updated) as updated_date
, convert_timezone('UTC','America/Los_Angeles',p.updated) as updated_timestamp_pst
, date(convert_timezone('UTC','America/Los_Angeles',p.updated)) as updated_date_pst
FROM
  base b