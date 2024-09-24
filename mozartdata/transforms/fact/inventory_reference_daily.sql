with
    shopify_channels as (
                            select
                                sku
                              , display_name
                              , snapshot_date
                              , lower(location_name) || ' - shopify inv' as channel
                              , quantity
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
)
as p
),

netsuite_locations as (
  select
    sku
    , display_name
    , snapshot_date
    , lower(location_name) || ' - netsuite inv' as location
    , quantity
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
  ) as p
),

stord_locations as (
  select
    sku
    , display_name
    , snapshot_date
    , lower(location_name) || ' - stord inv' as location
    , quantity
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
  ) as p
),

stord_reservations as (
  select
    sku
    , name
    , snapshot_date
    , lower(channel) || ' - stord resv' as channel
    , reservation_quantity
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
  ) as p
)

select distinct
    shopify.*
  , netsuite.* exclude (sku, display_name, snapshot_date)
  , stord.* exclude (sku, display_name, snapshot_date)
  , res.* exclude (sku, name, snapshot_date)
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