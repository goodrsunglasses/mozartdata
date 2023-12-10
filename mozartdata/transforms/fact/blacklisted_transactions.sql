--Super Basic draft
WITH
  tracking_map AS (
    SELECT
      order_id_edw,
      transaction_id_ns,
      number.trackingnumber,
      product_id_edw,
      record_type,
      total_quantity
    FROM
      fact.order_item_detail detail
      LEFT OUTER JOIN netsuite.trackingnumbermap map ON map.transaction = detail.transaction_id_ns
      LEFT OUTER JOIN netsuite.trackingnumber number ON number.id = map.trackingnumber
    WHERE
      record_type = 'itemfulfillment'
  ),
  duplicate_tracking_ifs AS (
    SELECT
      *,
      CASE
        WHEN COUNT(*) OVER (
          PARTITION BY
            ORDER_ID_EDW,
            TRACKINGNUMBER,
            record_type,
            PRODUCT_ID_EDW,
            TOTAL_QUANTITY
        ) > 1 THEN TRUE
        ELSE FALSE
      END AS duplicate_flag
    FROM
      tracking_map
  )
SELECT DISTINCT
  order_id_edw,
  transaction_id_ns,
  duplicate_flag
FROM
  duplicate_tracking_ifs
WHERE
  duplicate_flag = TRUE