WITH
  first_pass AS (
    SELECT DISTINCT
      order_id_edw,
      COUNT(
        DISTINCT CASE
          WHEN createdfrom IS NULL THEN transaction_id_ns
        END
      ) over (
        PARTITION BY
          order_id_edw
      ) AS potention_parents
    FROM
      staging.order_item_detail
    WHERE
      createdfrom IS NULL
      AND order_id_edw IN (
        'PB-ST63168/SM',
        '113-7256776-6975450',
        'G2361579'
      )
  )
  -- ,
  -- ranking AS (
    SELECT
      order_id_edw,
      record_type,
      transaction_id_ns,
      transaction_created_timestamp_pst,
      ROW_NUMBER() OVER (
        PARTITION BY
          order_id_edw
        ORDER BY
          transaction_created_timestamp_pst
      ) AS RANK
    FROM
      staging.order_item_detail
    WHERE
      (record_type = 'salesorder')
      OR (
        (
          record_type = 'cashsale'
          OR record_type = 'invoice'
        )
        AND createdfrom IS NULL
      ) and order_id_edw IN (
    'PB-ST63168/SM',
    '113-7256776-6975450',
    'G2361579'
  )
--   )
-- SELECT
--   order_id_edw,
--   record_type,
--   transaction_id_ns,
--   transaction_created_timestamp_pst,
--   CASE
--     WHEN MAX(record_type = 'salesorder') OVER (
--       PARTITION BY
--         order_id_edw
--     ) = 1 THEN CONCAT(order_id_edw, '#', RANK)
--     ELSE CAST(transaction_id_ns AS VARCHAR)
--   END AS custom_id
-- FROM
--   ranking
-- WHERE
--   order_id_edw IN (
--     'PB-ST63168/SM',
--     '113-7256776-6975450',
--     'G2361579'
--   )