WITH
  ranked_rows AS (
    SELECT
      sku,
      fivetran_snapshot_date_pst,
      location_name,
      total_quantity_available,
      ROW_NUMBER() OVER (
        PARTITION BY
          sku,
          location_name
        ORDER BY
          fivetran_snapshot_date_pst desc
      ) AS row_num
    FROM
      fact.netsuite_inventory_location
    WHERE
      location_name IN ('Stord LAS', 'Stord ATL')
  )
SELECT
  *
FROM
  ranked_rows
WHERE
  row_num =1 order by sku