/*
 Purpose: retrieves campaign history data from the snapchat_ads schema.

-- It joins the campaign_history table with a CTE (Common Table Expression)
-- latest_account_ids to fetch the latest account information for each campaign.

-- The query filters campaigns that started on or after January 1, 2024,
-- and excludes those with 'not used' in their name.

-- The result is ordered by campaign name in ascending order.

-- Used downstream in the snapchat_ads_daily_stats table primarily

 One row per Snapchat campaign id, which breaks down to one campaign per account id

 Base table: CTE root_table is used to get root table reference for scheduling in mozart.
 If no longer a base table, then remove CTE root_table.
*/

with root_table as (
    select
      *
    from
      mozart.pipeline_root_table
)
, latest_account_ids AS (
    -- This CTE selects the latest account information for each account ID.
    SELECT DISTINCT
        AD_ACCOUNT_HISTORY.id
        , AD_ACCOUNT_HISTORY.name
        , AD_ACCOUNT_HISTORY.CURRENCY
        , MAX(AD_ACCOUNT_HISTORY._FIVETRAN_SYNCED) OVER (
            PARTITION BY AD_ACCOUNT_HISTORY.id
            ORDER BY AD_ACCOUNT_HISTORY._FIVETRAN_SYNCED DESC
        ) AS sync_date -- this element is gets the latest updated row in account history
    FROM
        snapchat_ads.AD_ACCOUNT_HISTORY
)

SELECT
    cam_history.id AS campaign_id_snapchat
    , cam_history.name AS campaign_name_snapchat
    , cam_history.CREATED_AT AS create_datetime
    , cam_history.CREATED_AT::date AS create_date
    , cam_history.start_time AS start_datetime
    , cam_history.start_time::date AS start_date
    , cam_history.objective
    , cam_history.status
    , CASE
        WHEN (
                LOWER(cam_history.name) LIKE '%mof%'
                OR LOWER(cam_history.name) LIKE '%tof%'
        )
        THEN 'Awareness'
        WHEN LOWER(cam_history.name) LIKE '%bof%'
        THEN 'Performance'
        ELSE 'Other'
    END AS marketing_strategy
    , CASE
        WHEN LOWER(cam_history.name) LIKE '%mof%' THEN 'MOF'
        WHEN LOWER(cam_history.name) LIKE '%tof%' THEN 'TOF'
        WHEN LOWER(cam_history.name) LIKE '%bof%' THEN 'BOF'
        ELSE 'OTHER'
    END AS funnel_stage
    , cam_history.AD_ACCOUNT_ID AS account_id
    , acc_history.NAME AS account_name
    , acc_history.CURRENCY AS account_currency
FROM
    snapchat_ads.campaign_history AS cam_history
INNER JOIN
    latest_account_ids AS acc_history
    ON cam_history.AD_ACCOUNT_ID = acc_history.ID
QUALIFY
    -- selects the most recently updated row for each campaign in the campaign history table
    ROW_NUMBER() OVER (
        PARTITION BY cam_history.id ORDER BY cam_history.updated_at DESC
    ) = 1
ORDER BY
    cam_history.name