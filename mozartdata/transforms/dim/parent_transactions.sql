WITH
  distinct_order_lines AS ( --sanitize the data to just transaction level information from order_item_detail for later ranking
    SELECT DISTINCT
      order_id_edw,
      transaction_id_ns,
      transaction_created_timestamp_pst,
      record_type,
      createdfrom
    FROM
      staging.order_item_detail
    WHERE
      order_id_edw IN (
        'PB-ST63168/SM',
        '113-7256776-6975450',
        'G2361579'
      )
  ),
  ranking AS (--rank them for later concatination as well as counting the total amount per order_id_edw for when there is only one
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
      ) AS RANK,
      COUNT(*) OVER (
        PARTITION BY
          order_id_edw
      ) AS cnt
    FROM
      distinct_order_lines
    WHERE
      (record_type = 'salesorder')
      OR (
        (
          record_type = 'cashsale'
          OR record_type = 'invoice'
        )
        AND createdfrom IS NULL
      )
      OR (record_type = 'purchaseorder')
  )
SELECT --finally concatenate based on the logic of all sales orders first, then cashsales/invoices, then Purchaseorders
  order_id_edw,
  record_type,
  transaction_id_ns as parent_id,
  CASE
    WHEN MAX(record_type = 'salesorder') OVER (
      PARTITION BY
        order_id_edw
    ) = 1
    AND cnt > 1 THEN CONCAT(order_id_edw, '#', RANK)
    WHEN MAX(record_type IN ('cashsale', 'invoice')) OVER (
      PARTITION BY
        order_id_edw
    ) = 1
    AND cnt > 1 THEN CONCAT(order_id_edw, '#', RANK)
      WHEN MAX(record_type ='purchaseorder') OVER (
      PARTITION BY
        order_id_edw
    ) = 1
    AND cnt > 1 THEN CONCAT(order_id_edw, '#', RANK)
    ELSE order_id_edw
  END AS custom_id
FROM
  ranking