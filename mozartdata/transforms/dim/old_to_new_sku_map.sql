/*
 Purpose: Map old skus to new skus and new upcs
 Granularity: One row per old sku
 Primary key column: old_sku
 Joining:
    To old products: use column old_sku to sku
    To new products: use column new_sku to sku
 Notes: This data is human input. Please consider this when troubleshooting.
 */

select
    upc.old_sku -- PRIMARY KEY, most recommended for joining
  , upc.display_name -- Not recommended for joining but feasible for some tables
  , upc.category
  , upc.tier
  , upc.due_date_for_new_skus as due_date_for_new_skus
  , try_to_date(upc.due_date_for_new_skus) as new_sku_due_date
  , upc.new_skus              as new_sku -- Can be used to join new skus in product tables
  , upc.new_upcs              as new_upc
  , date(upc.po_placement) as po_placement_date
  , date(upc.estimated_arrival) as estimated_arrival_date
  , upc.status
  , upc.old_margin
  , upc.lens_type
  , case
        when upc.poly_lam like '%✅%'
            then true
        else false
    end                       as poly_lam_flag
  , case
        when upc.tac_niobium like '%✅%'
            then true
        else false
    end                       as tac_niobium_flag
  , upc.old_price
  , upc.new_price
from
    google_sheets.upc_cutover_skus as upc