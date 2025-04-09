-- create or replace table fact.bin_inventory_location
--     copy grants as
--The idea with this table is bin sourced daily inventory counts, aggregated using business logic because we had trouble tracking Lagoon inventory using macro snapshot tables
select
    location_name
  , sku
  , display_name
  , snapshot_date_fivetran
  , sum(quantity_available) as netsuite_total_available
  , sum(case
            when
                zone_name = 'General Zone' and bin_name not like 'Picked%' and bin_id != 1404
                then quantity_available--Baseline condition, the super specific sub portion of "available" inventory that's actually not reserved
            else 0
        end-- This is the crux of all our work here, translating the logic of whats actually available to purchase in the Lagoon to code
    )                       as edw_total_purchaseable
  , sum(case
            when zone_name = 'REI Zone'
                then quantity_available
            else 0
        end)--Added this as when it seemed incredibly helpful for figuring out where inventory may be hiding
                            as total_in_rei_zone
  , sum(case
            when bin_id = 1404
                then quantity_available
            else 0
        end)--Another one that takes more than half our "Available" inventory
                            as total_being_tagged
  , sum(quantity_picked)    as total_quantity_picked
from
    fact.netsuite_bin_inventory
where
    location_id =
    1 -- Filtering for only HQDC for the sake of this higher level table, since we have no bin/zone info for locations like Stord
  and snapshot_date_fivetran > '2025-01-01'--We only turned this on in March 2025, all the 2023 data should be irrelevant?
group by
    location_name
  , sku
  , display_name
  , snapshot_date_fivetran
order by
    snapshot_date_fivetran desc