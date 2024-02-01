--The overall approach to this table is to meticulously comb through the different netsuite record types ascociated with an order in an effort to cut down on system/user error caused duplicates
WITH
  first_pass AS ( --This is the first pass that just limits the query to the transactions that have an odd count of transactions
    SELECT
      order_id_ns,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'estimate' THEN transaction_id_ns
        END
      ) AS quote_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'vendorbill' THEN transaction_id_ns
        END
      ) AS bill_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'salesorder' THEN transaction_id_ns
        END
      ) AS salesorder_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'purchaseorder' THEN transaction_id_ns
        END
      ) AS purchaseorder_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'cashsale' THEN transaction_id_ns
        END
      ) AS cashsale_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'invoice' THEN transaction_id_ns
        END
      ) AS invoice_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'itemfulfillment' THEN transaction_id_ns
        END
      ) AS itemfulfillment_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'itemreceipt' THEN transaction_id_ns
        END
      ) AS itemreceipt_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'cashrefund' THEN transaction_id_ns
        END
      ) AS cashrefund_count
    FROM
      staging.order_item_detail
    GROUP BY
      order_id_ns
    HAVING
      salesorder_count > 1
      OR cashsale_count > 1
      OR invoice_count > 1
      OR itemfulfillment_count > 1
      OR cashrefund_count > 1
      OR quote_count > 1
      OR bill_count > 1
      OR purchaseorder_count > 1
      OR itemreceipt_count > 1
  ),

    if_dupes AS ( --Selecting all the IF dupes for tracking related checks
      SELECT
        first_pass.order_id_ns,
        transaction_id_ns
      FROM
        first_pass
        LEFT OUTER JOIN staging.order_item_detail detail ON detail.order_id_ns= first_pass.order_id_ns
      WHERE
        itemfulfillment_count > 1
    ),
    inv_dupes AS ( --Selecting all the Inv dupes for quantity related checks
      SELECT
        first_pass.order_id_ns,
        transaction_id_ns,
        SUM(
          CASE
            WHEN plain_name NOT IN ('Shipping', 'Tax') THEN total_quantity
            ELSE 0
          END
        ) invoice_qty,
        CASE
          WHEN invoice_qty = 0 THEN TRUE
          ELSE FALSE
        END AS dupe_flag
      FROM
        first_pass
        LEFT OUTER JOIN staging.order_item_detail detail ON detail.order_id_ns = first_pass.order_id_ns
      WHERE
        invoice_count > 1
      GROUP BY
        first_pass.order_id_ns,
        transaction_id_ns
    ),
    so_dupes AS ( -- Selecting all the SO Dupes for parent_transaction related sorting
      SELECT DISTINCT
        first_pass.order_id_ns,
        transaction_id_ns,
        FIRST_VALUE(transaction_id_ns) OVER (
          PARTITION BY
            first_pass.order_id_ns
          ORDER BY
            CASE
              WHEN record_type = 'salesorder'
              AND createdfrom IS NULL THEN 1
              WHEN record_type IN ('cashsale', 'invoice')
              AND createdfrom IS NULL THEN 2
              ELSE 3
            END,
            transaction_created_timestamp_pst ASC
        ) AS parent_id,
        CASE
          WHEN createdfrom IS NULL
          AND transaction_id_ns != parent_id THEN TRUE
          WHEN createdfrom != parent_id THEN TRUE
          ELSE FALSE
        END AS dupe_flag
      FROM
        first_pass
        LEFT OUTER JOIN staging.order_item_detail detail ON detail.order_id_ns = first_pass.order_id_ns
      WHERE
        salesorder_count > 1
    )
    --Here I'll have it select the original full list, then join with it depending on what CTE it came from and have there be a final boolean that will determine if te transaction_id_ns should be excluded
  SELECT DISTINCT --Had to add a distinct as adding in the secondary CTE join made a shitload of duplicates combined with the case when, you can see this if you remove the distinct and filter for 'CS-DENVERGOV070722'
    first_pass.*,
    CASE --this has to be is not null because if the flag is false then it won't show the transactions that "passed"
      WHEN so_dupes.dupe_flag IS NOT NULL THEN so_dupes.transaction_id_ns
      WHEN inv_dupes.dupe_flag IS NOT NULL THEN inv_dupes.transaction_id_ns
      ELSE NULL
    END AS transaction_id_ns,
    CASE --boolean switch that basically goes through each CTE, and if the given transaction had a true to it then display that cte's dupe flag, or else move on
      WHEN so_dupes.dupe_flag THEN so_dupes.dupe_flag
      WHEN inv_dupes.dupe_flag THEN inv_dupes.dupe_flag
      ELSE FALSE
    END AS dupe_flag
  FROM
    first_pass
    LEFT OUTER JOIN so_dupes ON so_dupes.order_id_ns = first_pass.order_id_ns
    LEFT OUTER JOIN inv_dupes ON inv_dupes.order_id_ns = first_pass.order_id_ns
  ORDER BY
    order_id_ns,
    dupe_flag