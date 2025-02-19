select
    email
  , first_name
  , last_name
  , points_earned
  , points_balance
  , referral_link
  , referred_by
  , last_seen
  , vip_tier
  , birth_month
  , birth_day
  , birth_year
  , anniversary_month
  , anniversary_day
  , anniversary_year
  , platform_account_created_at
  , try_to_timestamp(
        trim(
            replace(
                platform_account_created_at
                , ' UTC'
                , ''
            )
        )
        , 'YYYY-MM-DD HH24:MI:SS'
    )::date     as platform_account_created_at_date
  , created_at
  , try_to_timestamp(
        trim(
            replace(
                created_at
                , ' UTC'
                , ''
            )
        )
        , 'YYYY-MM-DD HH24:MI:SS'
    )::date     as created_at_date
  , phone_number
  , loyalty_eligible
  , opt_in_date as opt_in_date_string
  , try_to_timestamp(
        trim(
            replace(
                opt_in_date
                , ' UTC'
                , ''
            )
        )
        , 'YYYY-MM-DD HH24:MI:SS'
    )::date     as opt_in_date
  , referral_discount_code
from
    yotpo_exports.customer_report_010125_021225
union all
select
    email
  , first_name
  , last_name
  , points_earned
  , points_balance
  , referral_link
  , referred_by
  , last_seen
  , vip_tier
  , birth_month
  , birth_day
  , birth_year
  , anniversary_month
  , anniversary_day
  , anniversary_year
  , platform_account_created_at
  , try_to_timestamp(
        trim(
            replace(
                platform_account_created_at
                , ' UTC'
                , ''
            )
        )
        , 'YYYY-MM-DD HH24:MI:SS'
    )::date     as platform_account_created_at_date
  , created_at
  , try_to_timestamp(
        trim(
            replace(
                created_at
                , ' UTC'
                , ''
            )
        )
        , 'YYYY-MM-DD HH24:MI:SS'
    )::date     as created_at_date
  , phone_number
  , loyalty_eligible
  , opt_in_date as opt_in_date_string
  , try_to_timestamp(
        trim(
            replace(
                opt_in_date
                , ' UTC'
                , ''
            )
        )
        , 'YYYY-MM-DD HH24:MI:SS'
    )::date     as opt_in_date
  , referral_discount_code
from
    yotpo_exports.customer_report_120124_123124