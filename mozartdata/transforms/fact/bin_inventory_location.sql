-- create or replace table fact.bin_inventory_location
--     copy grants as
--The idea with this table is bin sourced daily inventory counts, aggregated using business logic because we had trouble tracking Lagoon inventory using macro snapshot tables
select
    final_location_name
  , sku
  , display_name
  , day
  , sum(case
            when
                final_zone_name in ('General Zone', 'Carton Flow Zone') and final_binnumber not like 'Picked%' and final_bin_id != 1404
                then final_carried_quantity_available--Baseline condition, the super specific sub portion of "available" inventory that's actually not reserved
            else 0
        end-- This is the crux of all our work here, translating the logic of whats actually available to purchase in the Lagoon to code
    )                       as edw_total_purchaseable
  , sum(final_carried_quantity_available) as netsuite_total_available

  , sum(case
            when final_zone_name = 'REI Zone'
                then final_carried_quantity_available
            else 0
        end)--Added this as when it seemed incredibly helpful for figuring out where inventory may be hiding
                            as total_in_rei_zone
  , sum(case
            when final_bin_id = 1404
                then final_carried_quantity_available
            else 0
        end)--Another one that takes more than half our "Available" inventory
                            as total_being_tagged
  , sum(final_quantity_picked)    as total_quantity_picked
from
    fact.netsuite_bin_inventory
where
    final_location_name =
    'HQ DC' -- Filtering for only HQDC for the sake of this higher level table, since we have no bin/zone info for locations like Stord

group by
    final_location_name
  , sku
  , display_name
  , day
order by
    day desc