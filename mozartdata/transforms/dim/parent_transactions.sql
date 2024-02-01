WITH
  distinct_order_lines AS ( --sanitize the data to just transaction level information from order_item_detail for later ranking
    SELECT DISTINCT
      order_id_ns,
      transaction_id_ns,
      transaction_created_timestamp_pst,
      record_type,
      createdfrom
    FROM
      staging.order_item_detail
  ),
  first_select AS ( --first select the applicable records based on the where clause then rank them based on transaction type
    SELECT
      ol1.order_id_ns,
      ol1.record_type,
      ol1.transaction_id_ns,
      ol1.transaction_created_timestamp_pst,
      ROW_NUMBER() OVER (
        PARTITION BY
          ol1.order_id_ns
        ORDER BY
          CASE ol1.record_type
            WHEN 'salesorder' THEN 1
            WHEN 'cashsale' THEN 2
            WHEN 'invoice' THEN 2
            WHEN 'purchaseorder' THEN 3
            ELSE 4
          END,
          ol1.transaction_created_timestamp_pst
      ) AS RANK
    FROM
      distinct_order_lines ol1
    LEFT OUTER JOIN
      distinct_order_lines ol2
    ON ol2.transaction_id_ns = ol1.createdfrom
    AND ol1.record_type = 'purchaseorder'
    WHERE
      (ol1.record_type = 'salesorder')
      OR (
        (
          ol1.record_type = 'cashsale'
          OR ol1.record_type = 'invoice'
        )
        AND ol1.createdfrom IS NULL
      )
      OR (
          (ol1.record_type = 'purchaseorder' AND ol1.createdfrom is null)
          OR (ol1.record_type = 'purchaseorder' AND ol2.order_id_ns != ol1.order_id_ns AND ol1.createdfrom is not null)
        )
  ),
  parent_type AS ( --quickly select the rank 1, so the most applicable parent's type for later sorting
    SELECT
      order_id_ns,
      record_type AS parent_type
    FROM
      first_select
    WHERE
      RANK = 1
  ),
  final_ranking AS ( --finally rerank everything only for the transaction types that are the same as the rank 1 that was previously gotten, this is to prevent there for example being multiple parents with different record types like in SO1746720
    SELECT
      first_select.order_id_ns,
      parent_type,
      first_select.record_type,
      first_select.transaction_id_ns,
      ROW_NUMBER() OVER (
        PARTITION BY
          first_select.order_id_ns
        ORDER BY
          transaction_created_timestamp_pst
      ) AS final_rank,
      COUNT(*) OVER (
        PARTITION BY
          first_select.order_id_ns
      ) AS cnt
    FROM
      first_select
      LEFT OUTER JOIN parent_type ON parent_type.order_id_ns = first_select.order_id_ns
    WHERE
      record_type = parent_type
  ),
  parents_ids AS (
    SELECT --finally concatenate the ones with a count>1 in the previous lists and give them new order_id_edw's with a # in them
      fr.order_id_ns,
      fr.record_type AS parent_record_type,
      fr.transaction_id_ns AS parent_id,
      fr.record_type,
      CASE
        WHEN MAX(
          CASE
            WHEN fr.record_type = 'salesorder' THEN 1
            ELSE 0
          END
        ) OVER (
          PARTITION BY
            fr.order_id_ns
        ) = 1
        AND cnt > 1 THEN CONCAT(fr.order_id_ns, '#', final_rank)
        WHEN MAX(
          CASE
            WHEN fr.record_type IN ('cashsale', 'invoice') THEN 1
            ELSE 0
          END
        ) OVER (
          PARTITION BY
            fr.order_id_ns
        ) = 1
        AND cnt > 1 THEN CONCAT(fr.order_id_ns, '#', final_rank)
        WHEN MAX(fr.record_type = 'purchaseorder') OVER (
          PARTITION BY
            fr.order_id_ns
        ) = 1
        AND cnt > 1 THEN CONCAT(fr.order_id_ns, '#', final_rank)
        ELSE fr.order_id_ns
      END AS order_id_edw
    FROM
      final_ranking fr
  ),
  distinct_order AS (
    SELECT DISTINCT
      order_id_ns,
      transaction_id_ns,
      createdfrom,
      record_type
    FROM
      staging.order_item_detail
  ),
  children AS (
    SELECT
      fr.order_id_ns,
      fr.record_type AS parent_record_type,
      fr.parent_id AS parent_id,
      od.transaction_id_ns,
      od.record_type,
      fr.order_id_edw
    FROM
      parents_ids fr
      inner JOIN distinct_order od ON (fr.parent_id = od.createdfrom and fr.order_id_ns = od.order_id_ns)
  ),
  parents AS (
    SELECT
      fr.order_id_ns,
      fr.record_type AS parent_record_type,
      fr.parent_id AS parent_id,
      od.transaction_id_ns,
      od.record_type,
      fr.order_id_edw
    FROM
      parents_ids fr
      inner JOIN distinct_order od ON (fr.parent_id = od.transaction_id_ns and fr.order_id_ns = od.order_id_ns)
  )
SELECT
  *
FROM
  children
UNION ALL
SELECT
  *
FROM
  parents