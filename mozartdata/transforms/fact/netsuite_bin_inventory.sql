CREATE OR REPLACE TABLE fact.netsuite_bin_inventory
            COPY GRANTS  as
select
    binv.bin_id
  , binv.binnumber
  , binv.zone_name
  , binv.location as location_id
  , binv.location_name
  , binv.item
  , prod.sku
  , prod.display_name
  , binv.snapshot_date_fivetran
  , binv.quantityavailable
  , binv.quantityonhand
  , binv.quantitypicked
  , binv.committedqtyperlocation
from
    staging.netsuite_bin_inventory binv
    left outer join dim.product    prod
        on prod.item_id_ns = binv.item