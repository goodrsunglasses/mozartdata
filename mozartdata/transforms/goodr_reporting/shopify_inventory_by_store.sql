select *
from (select distinct --select the distinct skus and days that they have snapshot data
                      sku,
                      fivetran_snapshot_date_pst,
                      store
      from fact.shopify_inventory)
    PIVOT
( MAX(QUANTITY) FOR STORE IN ('Specialty' AS Specialty, 'HQ DC' AS HQ_DC, 'Warehouse' AS Warehouse))