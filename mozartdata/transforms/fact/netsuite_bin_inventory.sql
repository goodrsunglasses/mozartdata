-- CREATE OR REPLACE TABLE fact.netsuite_bin_inventory
--             COPY GRANTS  as
select
    binv.bin_id
  , binv.binnumber as bin_name
  , binv.zone_name
  , binv.location as location_id
  , binv.location_name
  , binv.item
  , prod.sku
  , prod.display_name
  , binv.snapshot_date_fivetran
  , binv.quantityavailable as quantity_available
  , binv.quantityonhand as quantity_on_hand
  , binv.quantitypicked as quantity_picked
  , binv.committedqtyperlocation committed_qty_per_location
from
    staging.netsuite_bin_inventory binv
    left outer join dim.product    prod
        on prod.item_id_ns = binv.item