SELECT
    id as g_ads_campaign_id
  , name
FROM
    google_ads_us.campaign_history
QUALIFY
    ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) = 1