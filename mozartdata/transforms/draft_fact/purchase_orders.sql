WITH
  parent_info AS ( --first grab the netsuite info from dim.purchaseorders which implicitly should only have parent transactions from NS.
    SELECT
      purchase_orders.order_id_edw,
      purchase_orders.order_id_ns,
      purchase_orders.transaction_id_ns,
      line.name,
      line.vendor_id_ns
    FROM
      dim.purchase_orders
      LEFT OUTER JOIN draft_fact.purchase_order_line line ON line.transaction_id_ns = purchase_orders.transaction_id_ns
  ),
  aggregate_netsuite AS (
    SELECT DISTINCT
      parent_info.order_id_edw,
      FIRST_VALUE(transaction_date) OVER (
        PARTITION BY
          parent_info.order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'purchaseorder' THEN 1
            ELSE 2
          END,
          transaction_created_timestamp_pst asc
      ) AS purchase_date,
      FIRST_VALUE(transaction_date) OVER (
        PARTITION BY
          parent_info.order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'itemreceipt' THEN 1
            ELSE 2
          END,
          transaction_created_timestamp_pst asc
      ) AS fulfillment_date,
      parent_info.vendor_id_ns,
      parent_info.name
    FROM
      parent_info
      LEFT OUTER JOIN draft_fact.purchase_order_line line ON line.order_id_edw = parent_info.order_id_edw
  ),
  aggregates AS (
    SELECT
      order_id_edw,
      AVG(unit_rate_ordered) AS avg_unit_rate_ordered,
      AVG(unit_rate_billed) AS avg_unit_rate_billed,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_ordered
          ELSE 0
        END
      ) AS quantity_ordered,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_billed
          ELSE 0
        END
      ) AS quantity_billed,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_received
          ELSE 0
        END
      ) AS quantity_received,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_ordered
          ELSE 0
        END
      ) AS rate_ordered,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_billed
          ELSE 0
        END
      ) AS rate_billed,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_ordered
          ELSE 0
        END
      ) AS amount_ordered,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_billed
          ELSE 0
        END
      ) AS amount_billed,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_received
          ELSE 0
        END
      ) AS amount_received
    FROM
      fact.purchase_order_item
    GROUP BY
      order_id_edw
  )
SELECT
  order_level.order_id_edw,
  order_level.name vendor_name,
  order_level.vendor_id_ns,
  order_level.purchase_date,
  DATE(order_level.purchase_date) AS order_date_pst,
  order_level.fulfillment_date,
  DATE(order_level.fulfillment_date) AS fulfillment_date_pst,
  avg_unit_rate_ordered,
  avg_unit_rate_billed,
  quantity_ordered,
  quantity_billed,
  quantity_received,
  rate_ordered,
  rate_billed,
  amount_ordered,
  amount_billed,
  amount_received
FROM
  aggregate_netsuite order_level
  LEFT OUTER JOIN aggregates ON aggregates.order_id_edw = order_level.order_id_edw