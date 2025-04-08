CREATE OR REPLACE TABLE staging.netsuite_bin_inventory
            COPY GRANTS  as
with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )
select
    binv.binnumber               as bin_id
  , bins.binnumber
  , bins.custrecord_rfs_pickzone as zone_id
  , zone.name                    as zone_name
  , binv.location
  , loc.fullname                 as location_name
  , binv.item
  , binv._fivetran_synced        as snapshot_timestamp_fivetran
  , date(binv._fivetran_synced)  as snapshot_date_fivetran
  , binv.quantityavailable
  , binv.quantityonhand
  , binv.quantitypicked
  , binv.committedqtyperlocation
  , binv.committedqtyperseriallotnumber
  , binv.committedqtyperseriallotnumberlocation
from
    netsuite.bininventorybalance                   binv
    left outer join netsuite.bin                   bins
        on bins.id = binv.binnumber
    left outer join netsuite.location              loc
        on loc.id = binv.location
    left outer join netsuite.customrecord_rfs_zone zone
        on zone.id = bins.custrecord_rfs_pickzone
order by
    snapshot_date_fivetran desc

