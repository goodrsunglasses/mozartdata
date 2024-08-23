/**
 * This SQL query retrieves distinct campaign and account information from Google Ads.
 * It joins the campaign_history and account_history tables based on the customer_id.
 *
 * @param {table} google_ads_us.campaign_history - The table containing campaign history data.
 * @param {table} google_ads_us.account_history - The table containing account history data.
 *
 * @returns {table} A table with the following columns:
 * - campaign_id_g_ads: The unique identifier of the campaign in Google Ads.
 * - campaign_name: The name of the campaign.
 * - account_id_g_ads: The unique identifier of the account in Google Ads.
 * - account_name: The descriptive name of the account.
 *
 * Used downstream in the google_ads_daily_stats table primarily
 */

with
    account_names as (
                         select distinct
                             id
                           , descriptive_name
                         from
                             google_ads_us.account_history
    )

select distinct
    ch.id               as campaign_id_g_ads
  , ch.name             as campaign_name
  , an.id               as account_id_g_ads
  , an.descriptive_name as account_name
from
    google_ads_us.campaign_history as ch
    inner join
        account_names              as an
            on
            ch.customer_id = an.id