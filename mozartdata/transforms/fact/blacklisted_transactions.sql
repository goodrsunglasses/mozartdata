WITH
  tracking_map AS (
    SELECT
      tran.custbody_goodr_shopify_order order_id_edw,
      tran.id ns_id,
      number.trackingnumber tracking,
      tran.recordtype record_type,
      SUM(quantity) total_quantity
    FROM
      netsuite.transaction tran
      LEFT OUTER JOIN netsuite.transactionline line ON tran.id = line.transaction
      LEFT OUTER JOIN netsuite.trackingnumbermap map ON map.transaction = tran.id
      LEFT OUTER JOIN netsuite.trackingnumber number ON number.id = map.trackingnumber
    WHERE
      recordtype = 'itemfulfillment'
      AND tracking IS NOT NULL
      AND itemtype IN (
        'InvtPart',
        'Assembly',
        'OthCharge',
        'NonInvtPart',
        'Payment'
      )
      AND (
        CASE
          WHEN recordtype = 'itemfulfillment'
          AND accountinglinetype IN ('COGS') THEN TRUE
          ELSE FALSE
        END
      )
    GROUP BY
      order_id_edw,
      ns_id,
      tracking,
      record_type
  ),
  step_1 AS (
    SELECT
      *,
      CASE
        WHEN COUNT(*) OVER (
          PARTITION BY
            ORDER_ID_EDW,
            TRACKING,
            record_type,
            TOTAL_QUANTITY
        ) > 1 THEN TRUE
        ELSE FALSE
      END AS duplicate_flag
    FROM
      tracking_map
  ),
  individual_items AS (
    SELECT
      order_id_edw,
      ns_id,
      tracking,
      record_type,
      item,
      quantity
    FROM
      step_1
      LEFT OUTER JOIN netsuite.transactionline line ON line.transaction = step_1.ns_id
    WHERE
      duplicate_flag = TRUE
      AND itemtype IN (
        'InvtPart',
        'Assembly',
        'OthCharge',
        'NonInvtPart',
        'Payment'
      )
      AND (
        CASE
          WHEN record_type = 'itemfulfillment'
          AND accountinglinetype IN ('COGS') THEN TRUE
          ELSE FALSE
        END
      )
  ),
  final_step AS (
    SELECT
      *,
      CASE
        WHEN COUNT(*) OVER (
          PARTITION BY
            ORDER_ID_EDW,
            TRACKING,
            item,
            quantity
        ) > 1 THEN TRUE
        ELSE FALSE
      END AS duplicate_flag_final
    FROM
      individual_items
  )
SELECT
  *
FROM
  final_step
WHERE
  duplicate_flag_final = TRUE