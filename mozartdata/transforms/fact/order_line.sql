WITH
  parent_transaction AS (
    SELECT DISTINCT
      order_id_edw,
      FIRST_VALUE(transaction_id_ns) OVER (
        PARTITION BY
          order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'salesorder'
            AND createdfrom IS NULL THEN 1
            WHEN record_type IN ('cashsale', 'invoice')
            AND createdfrom IS NULL THEN 2
            ELSE 3
          END,
          transaction_timestamp_pst ASC
      ) AS parent_id
    FROM
      fact.order_item_detail
  )
SELECT DISTINCT
  CONCAT(item_detail.order_id_edw, '_', transaction_id_ns) AS order_line_id,
  item_detail.order_id_edw,
  item_detail.transaction_id_ns,
  item_detail.record_type,
  channel.name AS channel,
  entity AS customer_id_ns,
  customer.email,
  CASE
    WHEN record_type = 'cashrefund' THEN TRUE
    ELSE FALSE
  END AS has_refund,
  CASE
    WHEN memo LIKE '%RMA%' THEN TRUE
    ELSE FALSE
  END AS is_exchange,
  transaction_timestamp_pst,
  DATE(tran.trandate) AS transaction_event_date,
  CASE
    WHEN full_status LIKE ANY(
      '%Closed',
      '%Voided',
      '%Undefined',
      '%Rejected',
      '%Unapproved',
      '%Not Deposited'
    ) THEN TRUE
    ELSE FALSE
  END AS status_flag_edw,
  item_detail.createdfrom,
  tran.custbody_boomi_orderid,
  CASE
    WHEN parent_id IS NOT NULL THEN TRUE
    ELSE FALSE
  END AS parent_transaction
FROM
  fact.order_item_detail item_detail
  LEFT OUTER JOIN parent_transaction ON item_detail.transaction_id_ns = parent_transaction.parent_id
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = item_detail.transaction_id_ns
  LEFT OUTER JOIN dim.channel channel ON channel.channel_id_ns = tran.cseg7
  LEFT OUTER JOIN netsuite.customer customer ON customer.id = tran.entity
WHERE
  record_type IN (
    'cashsale',
    'itemfulfillment',
    'salesorder',
    'cashrefund',
    'invoice'
  )