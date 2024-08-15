with shopify_inventory as (
  SELECT DISTINCT --select the distinct skus and days that they have snapshot data
                  sku
  ,               snapshot_date
  ,               store
  ,               coalesce(quantity,0) quantity
  FROM
    fact.shopify_inventory
  )
    SELECT *
    FROM
      shopify_inventory
        PIVOT
        ( SUM(quantity) FOR store IN ('Goodr.ca' ,'Goodrwill' ,'Specialty', 'Specialty CAN', 'Goodr.com' ))

