-- CREATE OR REPLACE TABLE fact.netsuite_bin_inventory
--             COPY GRANTS  as
with
    distinct_skus as (
                         select distinct
                             item
                           , sku
                           , location
                         from
                             staging.netsuite_bin_inventory binv
                             left outer join dim.product    prod
                                 on prod.item_id_ns = binv.item
                     )
  , days as (
                         select
                             date
                         from
                             dim.date
                     )
  , sku_date_grid as (
                         select
                             s.sku
                           , s.item
                           , s.location
                           , c.date
                         from
                             distinct_skus   s
                             cross join days c
                     )
select
    grid.date
  , grid.location
  , grid.sku
  , prod.display_name
  , binv.bin_id
  , binv.binnumber               as bin_name
  , binv.zone_name
  , binv.location                as location_id
  , binv.location_name
  , binv.snapshot_date_fivetran
  , binv.quantityavailable       as quantity_available
  , binv.quantityonhand          as quantity_on_hand
  , binv.quantitypicked          as quantity_picked
  , binv.committedqtyperlocation as committed_qty_per_location
from
    sku_date_grid                      grid
    left outer join
        staging.netsuite_bin_inventory binv
            on binv.snapshot_date_fivetran = grid.date and binv.item = grid.item and binv.location = grid.location
    left outer join dim.product        prod
        on prod.item_id_ns = grid.item
where
      date = '2025-04-02'
  and grid.item = 105


--date >= '2025-04-01'--This is the start of all the relevant data unless we backfill
