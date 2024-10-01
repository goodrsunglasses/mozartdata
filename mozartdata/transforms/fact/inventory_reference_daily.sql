with
    shopify_channels as (
                            select
                                sku
                              , display_name
                              , snapshot_date
                              , lower(location_name) || ' - shopify inv' as channel
                              , ifnull(quantity, 0) as quantity
                            from
                                fact.inventory_location
                            where
                                  lower(source) = 'shopify'
                              and display_name is not null
                              and lower(display_name) not like '%pre-pack%'
                              and lower(display_name) not like '%pre pack%'
                        )
  , shopify_channels_pivot as (
                            select
                                *
                            from
                                shopify_channels
    pivot
( sum(quantity) for channel in (
    select distinct
    channel
    from
    shopify_channels
    )
    default on null (0)
)
as p
),

netsuite_locations as (
  select
    sku
    , display_name
    , snapshot_date
    , lower(location_name) || ' - netsuite inv' as location
    , ifnull(quantity, 0) as quantity
  from
    fact.inventory_location
  where
    lower(source) = 'netsuite'
    and display_name is not null
    and lower(display_name) not like '%pre-pack%'
    and lower(display_name) not like '%pre pack%'
    and lower(location_name) != 'hq dc - goodrglobal - do not use'
    and lower(location_name) != 'hq damaged'
    and lower(location_name) != 'hq dc - rei - do not use'
    and lower(location_name) != 'pyramid'

),

netsuite_locations_pivot as (
  select
    *
  from
    netsuite_locations
  pivot(
    sum(quantity) for location in (
      select distinct
        location
      from
        netsuite_locations
    )
    default on null (0)
  ) as p
),

stord_locations as (
  select
    sku
    , display_name
    , snapshot_date
    , lower(location_name) || ' - stord inv' as location
    , ifnull(quantity, 0) as quantity
  from
    fact.inventory_location
  where
    lower(source) = 'stord'
    and display_name is not null
    and lower(display_name) not like '%pre-pack%'
    and lower(display_name) not like '%pre pack%'
),

stord_locations_pivot as (
  select
    *
  from
    stord_locations
  pivot(
    sum(quantity) for location in (
      select distinct
        location
      from
        stord_locations
    )
    default on null (0)
  ) as p
),

stord_reservations as (
  select
    sku
    , name
    , snapshot_date
    , lower(channel) || ' - stord resv' as channel
    , ifnull(reservation_quantity, 0) as reservation_quantity
  from
    fact.stord_inventory_reservations
  where
    lower(channel) not in (
      'transfer orders'
    )
),

stord_reservations_pivot as (
  select
    *
  from
    stord_reservations
  pivot(
    sum(reservation_quantity) for channel in (
      select distinct
        channel
      from
        stord_reservations
    )
    default on null (0)
  ) as p
)

select distinct
    shopify.sku
  , shopify.display_name
  , shopify.snapshot_date
  , coalesce(shopify."'goodr.ca - shopify inv'", 0)                  as goodr_ca_shopify_inv
  , coalesce(shopify."'goodr.com - shopify inv'", 0)                 as goodr_com_shopify_inv
  , coalesce(shopify."'goodrwill - shopify inv'", 0)                 as goodrwill_shopify_inv
  , coalesce(shopify."'specialty - shopify inv'", 0)                 as specialty_shopify_inv
  , coalesce(shopify."'specialty can - shopify inv'", 0)             as specialty_can_shopify_inv
  , coalesce(netsuite."'donation - netsuite inv'", 0)                as donation_netsuite_inv
  , coalesce(netsuite."'drop ship - netsuite inv'", 0)               as drop_ship_netsuite_inv
  , coalesce(netsuite."'hq dc - netsuite inv'", 0)                   as hq_dc_netsuite_inv
  , coalesce(netsuite."'lensabl den - netsuite inv'", 0)             as lensabl_den_netsuite_inv
  , coalesce(netsuite."'qc pending - do not use - netsuite inv'", 0) as qc_pending_do_not_use_netsuite_inv
  , coalesce(netsuite."'retail - cabana damages - netsuite inv'", 0) as retail_cabana_damages_netsuite_inv
  , coalesce(netsuite."'retail - goodrcabana - netsuite inv'", 0)    as retail_goodrcabana_netsuite_inv
  , coalesce(netsuite."'stord atl - netsuite inv'", 0)               as stord_atl_netsuite_inv
  , coalesce(netsuite."'stord hold - netsuite inv'", 0)              as stord_hold_netsuite_inv
  , coalesce(netsuite."'stord las - netsuite inv'", 0)               as stord_las_netsuite_inv
  , coalesce(netsuite."'wh amazon - netsuite inv'", 0)               as wh_amazon_netsuite_inv
  , coalesce(netsuite."'wh amazon canada - netsuite inv'", 0)        as wh_amazon_canada_netsuite_inv
  , coalesce(stord."'atls001 - stord inv'", 0)                       as atls001_stord_inv
  , coalesce(stord."'lass002 - stord inv'", 0)                       as lass002_stord_inv
  , coalesce(res."'goodr.ca - stord resv'", 0)                       as goodr_ca_stord_resv
  , coalesce(res."'goodr.com - stord resv'", 0)                      as goodr_com_stord_resv
  , coalesce(res."'sellgoodr.ca - stord resv'", 0)                   as sellgoodr_ca_stord_resv
  , coalesce(res."'sellgoodr.com - stord resv'", 0)                  as sellgoodr_com_stord_resv
from
    shopify_channels_pivot       as shopify
    left join
        netsuite_locations_pivot as netsuite
            on
            shopify.sku = netsuite.sku
                and shopify.snapshot_date = netsuite.snapshot_date
    left join
        stord_locations_pivot    as stord
            on
            shopify.sku = stord.sku
                and shopify.snapshot_date = stord.snapshot_date
    left join
        stord_reservations_pivot as res
            on
            shopify.sku = res.sku
                and shopify.snapshot_date = res.snapshot_date
order by
    shopify.snapshot_date desc