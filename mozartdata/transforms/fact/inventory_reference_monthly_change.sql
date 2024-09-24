with
    month_starts_cte as (
                            select
                                *
                            from
                                fact.inventory_reference_daily
                            where
                                date_trunc(month, snapshot_date::date) = snapshot_date
                            order by
                                snapshot_date asc
    )

select
    sku
  , display_name
  , snapshot_date as month_start
  , ifnull(
        "'goodr.ca - shopify inv'", 0
    ) - ifnull(
        lag(
            "'goodr.ca - shopify inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as goodr_ca_shopify_inv_mom_diff
  , ifnull(
        "'goodr.com - shopify inv'", 0
    ) - ifnull(
        lag(
            "'goodr.com - shopify inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as goodr_com_shopify_inv_mom_diff
  , ifnull(
        "'goodrwill - shopify inv'", 0
    ) - ifnull(
        lag(
            "'goodrwill - shopify inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as goodrwill_shopify_inv_mom_diff
  , ifnull(
        "'specialty - shopify inv'", 0
    ) - ifnull(
        lag(
            "'specialty - shopify inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as specialty_shopify_inv_mom_diff
  , ifnull(
        "'specialty can - shopify inv'", 0
    ) - ifnull(
        lag(
            "'specialty can - shopify inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as specialty_can_shopify_inv_mom_diff
  , ifnull(
        "'donation - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'donation - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as donation_netsuite_inv_mom_diff
  , ifnull(
        "'drop ship - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'drop ship - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as drop_ship_netsuite_inv_mom_diff
  , ifnull(
        "'hq dc - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'hq dc - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as hq_dc_netsuite_inv_mom_diff
  , ifnull(
        "'lensabl den - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'lensabl den - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as lensabl_den_netsuite_inv_mom_diff
  , ifnull(
        "'qc pending - do not use - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'qc pending - do not use - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as qc_pending_netsuite_inv_mom_diff
  , ifnull(
        "'retail - cabana damages - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'retail - cabana damages - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as retail_cabana_damages_netsuite_inv_mom_diff
  , ifnull(
        "'stord atl - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'stord atl - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as stord_atl_netsuite_inv_mom_diff
  , ifnull(
        "'stord hold - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'stord hold - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as stord_hold_netsuite_inv_mom_diff
  , ifnull(
        "'stord las - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'stord las - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as stord_las_netsuite_inv_mom_diff
  , ifnull(
        "'wh amazon - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'wh amazon - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as wh_amazon_netsuite_inv_mom_diff
  , ifnull(
        "'wh amazon canada - netsuite inv'", 0
    ) - ifnull(
        lag(
            "'wh amazon canada - netsuite inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as wh_amazon_canada_netsuite_inv_mom_diff
  , ifnull(
        "'atls001 - stord inv'", 0
    ) - ifnull(
        lag(
            "'atls001 - stord inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as atls001_stord_inv_mom_diff
  , ifnull(
        "'lass002 - stord inv'", 0
    ) - ifnull(
        lag(
            "'lass002 - stord inv'"
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0)      as lass002_stord_inv_mom_diff
from
    month_starts_cte
order by
    sku
