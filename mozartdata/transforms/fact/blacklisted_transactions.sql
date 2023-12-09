WITH
  tracking_map AS (
    SELECT
      order_id_edw,
      transaction_id_ns,
      number.trackingnumber,
      product_id_edw,
      total_quantity
    FROM
      fact.order_item_detail detail
      LEFT OUTER JOIN netsuite.trackingnumbermap map ON map.transaction = detail.transaction_id_ns
      LEFT OUTER JOIN netsuite.trackingnumber number ON number.id = map.trackingnumber
    WHERE
      order_id_edw = 'SG-CHIMAR2022'
  )
SELECT
  *,
  CASE
    WHEN COUNT(*) OVER (
      PARTITION BY
        ORDER_ID_EDW,
        TRACKINGNUMBER,
        PRODUCT_ID_EDW,
        TOTAL_QUANTITY
    ) > 1 THEN 'Flag'
    ELSE 'No Flag'
  END AS Flag
FROM
  tracking_map