with
    staging as (
                   select
                       binv.*
                     , prod.sku
                     , prod.display_name
                   from

                       staging.netsuite_bin_inventory binv
                       left outer join dim.product    prod
                           on prod.item_id_ns = binv.item
                   where
                         binv.location = 1
                     and snapshot_date_fivetran >= '2025-04-01'
               )
  , distinct_skus as (
                   select distinct
                       item
                     , sku
                     , display_name
                     , location
                     , location_name
                   from
                       staging binv
               )
  , days as (
                   select
                       date as day
                   from
                       dim.date
                   where
                       date between '2025-04-01' and current_date()
               )
  , sku_date_grid as (
                   select
                       s.sku
                     , s.display_name
                     , s.item
                     , s.location
                     , s.location_name
                     , c.day
                   from
                       distinct_skus   s
                       cross join days c
               )
  , inventory_with_all_dates as (
                                    -- Left join to get all records per item/date (could be multiple shelves or none)
                   select
                       grid.sku
                     , grid.display_name
                     , grid.day
                     , binv.bin_id
                     , binv.location_name
                     , binv.binnumber
                     , binv.zone_name
                     , binv.quantityavailable       as quantity_available
                     , binv.quantityonhand          as quantity_on_hand
                     , binv.quantitypicked          as quantity_picked
                     , binv.committedqtyperlocation as committed_qty_per_location
                   from
                       sku_date_grid     grid
                       left join staging binv
                           on grid.sku = binv.sku
                           and grid.day = binv.snapshot_date_fivetran
               )
  , bin_summary as (
                       -- Summarize per item + date
                   select
                       sku
                     , display_name
                     , day
                       -- If there are no shelf entries, we'll get NULLs
                     , count(bin_id) as shelf_count
                   from
                       inventory_with_all_dates
                   group by
                       all
               )
  , missing_day as
        (
                   select
                       sku
                     , display_name
                     , day
                     , shelf_count
                   from
                       bin_summary
                   where
                       shelf_count = 0
               )
  , last_day_with_inv as (
                   select
                       sku
                     , day
                     , shelf_count
                   from
                       bin_summary
                   where
                       shelf_count > 0
               )
  , last_day_data as
        (
                   select
                       a.sku
                     , a.day
                     , b.bin_id
                     , b.zone_name
                     , b.binnumber
                     , b.location_name
                     , b.quantity_available
                     , b.quantity_on_hand
                     , b.quantity_picked
                     , b.committed_qty_per_location
                     , 1 as shelf_count
                   from
                       last_day_with_inv            a
                       inner join
                           inventory_with_all_dates b
                               on a.sku = b.sku
                               and a.day = b.day
               )
  , missing_day_fallback_dates as
        (
                   select
                       m.day
                     , m.sku
                     , m.display_name
                     , ld.day                        as fallback_day
                     , ld.location_name              as fallback_location_name
                     , ld.bin_id                     as fallback_bin_id
                     , ld.binnumber                  as fallback_binnumber
                     , ld.zone_name                  as fallback_zone_name
                     , ld.quantity_available         as fallback_quantity_available
                     , ld.quantity_on_hand           as fallback_quantity_on_hand
                     , ld.quantity_picked            as fallback_quantity_picked
                     , ld.committed_qty_per_location as fallback_committed_qty_per_location
                   from
                       missing_day       m
                       left join
                           last_day_data ld
                               on ld.day < m.day
                               and ld.sku = m.sku
                   qualify
                       rank() over (partition by m.day, m.sku order by ld.day desc) = 1
               )


select
    iad.sku
  , iad.display_name
  , iad.bin_id
  , iad.day
    --     is_fallback,
  , coalesce(location_name, fallback_location_name)                           as final_location_name
  , coalesce(bin_id, fallback_bin_id)                                         as final_bin_id
  , coalesce(binnumber, fallback_binnumber)                                   as final_binnumber
  , coalesce(zone_name, fallback_zone_name)                                   as final_zone_name
  , coalesce(quantity_available, fallback_quantity_available)                 as final_carried_quantity_available
  , coalesce(quantity_on_hand, fallback_quantity_on_hand)                     as final_quantity_on_hand
  , coalesce(quantity_picked, fallback_quantity_picked)                       as final_quantity_picked
  , coalesce(committed_qty_per_location, fallback_committed_qty_per_location) as final_committed_qty_per_location

from
    inventory_with_all_dates             iad
    left join missing_day_fallback_dates m
        on iad.sku = m.sku and iad.day = m.day
order by
    iad.sku
  , iad.day
  , final_bin_id;