/*
questions - 
do we use loyalty or swell?
suppressions list is always null
*/
SELECT
  p.profile_id as profile_id_klaviyo
, p.created as created_timestamp
, date(p.created) as created_date
, convert_timezone('UTC', 'America/Los_Angeles', p.created) as created_timestamp_pst
, date(convert_timezone('UTC', 'America/Los_Angeles', p.created)) as created_date_pst
, p.email
, p.first_name
, p.last_name
, p.title
, p.location:ADDRESS1::varchar as address_1
, p.location:ADDRESS2::varchar as address_2
, p.location:CITY::varchar as city
, p.location:REGION::varchar as region
, p.location:ZIP::varchar as zip_code
, p.location:COUNTRY::varchar as country
, p.location:TIMEZONE::varchar as timezone
, p.location:LATITUDE::varchar as latitude
, p.location:LONGITUDE::varchar as longitude
, p.phone_number
, p._organization as company
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
  klaviyo_portable.klaviyo_v2_profiles_8589937320 p