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
        goodr_ca_shopify_inv - lag(
            goodr_ca_shopify_inv
                               ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as goodr_ca_shopify_inv_mom_diff
  , ifnull(
        goodr_com_shopify_inv - lag(
            goodr_com_shopify_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as goodr_com_shopify_inv_mom_diff
  , ifnull(
        goodrwill_shopify_inv - lag(
            goodrwill_shopify_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as goodrwill_shopify_inv_mom_diff
  , ifnull(
        specialty_shopify_inv - lag(
            specialty_shopify_inv
                                ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as specialty_shopify_inv_mom_diff
  , ifnull(
        specialty_can_shopify_inv - lag(
            specialty_can_shopify_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as specialty_can_shopify_inv_mom_diff
  , ifnull(
        donation_netsuite_inv - lag(
            donation_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as donation_netsuite_inv_mom_diff
  , ifnull(
        drop_ship_netsuite_inv - lag(
            drop_ship_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as drop_ship_netsuite_inv_mom_diff
  , ifnull(
        hq_dc_netsuite_inv - lag(
            hq_dc_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as hq_dc_netsuite_inv_mom_diff
  , ifnull(
        lensabl_den_netsuite_inv - lag(
            lensabl_den_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as lensabl_den_netsuite_inv_mom_diff
  , ifnull(
        qc_pending_do_not_use_netsuite_inv - lag(
            qc_pending_do_not_use_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as qc_pending_netsuite_inv_mom_diff
  , ifnull(
        retail_cabana_damages_netsuite_inv - lag(
            retail_cabana_damages_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as retail_cabana_damages_netsuite_inv_mom_diff
  , ifnull(
        retail_goodrcabana_netsuite_inv - lag(
            retail_goodrcabana_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as retail_goodrcabana_netsuite_inv_mom_diff
  , ifnull(
        stord_atl_netsuite_inv - lag(
            stord_atl_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as stord_atl_netsuite_inv_mom_diff
  , ifnull(
        stord_hold_netsuite_inv - lag(
            stord_hold_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as stord_hold_netsuite_inv_mom_diff
  , ifnull(
        stord_las_netsuite_inv - lag(
            stord_las_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as stord_las_netsuite_inv_mom_diff
  , ifnull(
        wh_amazon_netsuite_inv - lag(
            wh_amazon_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as wh_amazon_netsuite_inv_mom_diff
  , ifnull(
        wh_amazon_canada_netsuite_inv - lag(
            wh_amazon_canada_netsuite_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as wh_amazon_canada_netsuite_inv_mom_diff
  , ifnull(
        atls001_stord_inv - lag(
            atls001_stord_inv
        ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as atls001_stord_inv_mom_diff
  , ifnull(
        lass002_stord_inv - lag(
            lass002_stord_inv
                            ) over (
                partition by sku
                order by snapshot_date
                )
        , 0) as lass002_stord_inv_mom_diff
from
    month_starts_cte
order by
    sku
