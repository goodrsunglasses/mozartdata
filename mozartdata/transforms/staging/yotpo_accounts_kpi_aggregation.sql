with
  root_table as (
    select
      *
    from
      mozart.pipeline_root_table
  )
  , union_cte as (
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
                       , platform_account_created_at as platfrom_account_created_at_string
                       , created_at                  as created_at_string
                       , phone_number
                       , loyalty_eligible
                       , opt_in_date                 as opt_in_date_string
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
                       , created_at
                       , phone_number
                       , loyalty_eligible
                       , opt_in_date
                       , referral_discount_code
                     from
                         yotpo_exports.customer_report_120124_123124
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
                       , created_at
                       , phone_number
                       , loyalty_eligible
                       , opt_in_date
                       , referral_discount_code
                     from
                         yotpo_exports.customer_report_021325_030925
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
                       , created_at
                       , phone_number
                       , loyalty_eligible
                       , opt_in_date
                       , referral_discount_code
                     from
                         yotpo_exports.customer_report_031025_033125
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
                       , created_at
                       , phone_number
                       , loyalty_eligible
                       , opt_in_date
                       , referral_discount_code
                     from
                         yotpo_exports.customer_report_20250401_20250409
    )
select
    union_cte.email
  , union_cte.first_name
  , union_cte.last_name
  , union_cte.points_earned
  , union_cte.points_balance
  , union_cte.referral_link
  , union_cte.referred_by
  , union_cte.last_seen
  , union_cte.vip_tier
  , union_cte.birth_month
  , union_cte.birth_day
  , union_cte.birth_year
  , union_cte.anniversary_month
  , union_cte.anniversary_day
  , union_cte.anniversary_year
  , union_cte.platfrom_account_created_at_string
  , try_to_timestamp(
        trim(
            replace(
                union_cte.platfrom_account_created_at_string
                , ' UTC'
                , ''
            )
        )
        , 'YYYY-MM-DD HH24:MI:SS'
    )::date     as platform_account_created_at_date
  , union_cte.created_at_string
  , try_to_timestamp(
        trim(
            replace(
                union_cte.created_at_string
                , ' UTC'
                , ''
            )
        )
        , 'YYYY-MM-DD HH24:MI:SS'
    )::date     as created_at_date
  , union_cte.phone_number
  , union_cte.loyalty_eligible
  , union_cte.opt_in_date_string
  , try_to_timestamp(
        trim(
            replace(
                union_cte.opt_in_date_string
                , ' UTC'
                , ''
            )
        )
        , 'YYYY-MM-DD HH24:MI:SS'
    )::date     as opt_in_date
  , union_cte.referral_discount_code
from
    union_cte