WITH
  line_amount AS (
    SELECT
      gt.transaction_id_ns,
      SUM(gt.net_amount) net_amount
    FROM
      fact.gl_transaction gt
    WHERE
      gt.account_number BETWEEN 4000 AND 4999
    GROUP BY
      gt.transaction_id_ns
  )
SELECT DISTINCT
  CONCAT(
    item_detail.order_id_edw,
    '_',
    item_detail.transaction_id_ns
  ) AS order_line_id,
  tran.shippingaddress shipping_address_ns,
  item_detail.order_id_edw,
  item_detail.order_id_ns,
  item_detail.transaction_id_ns,
  item_detail.is_parent,
  tran.tranid AS transaction_number_ns,
  item_detail.full_status AS transaction_status_ns,
  item_detail.record_type,
  channel.name AS channel,
  tran.saleschannel AS inventory_bucket,
  entity AS customer_id_ns,
  customer.email,
  item_detail.warranty_order_id_ns,
  CASE
    WHEN item_detail.record_type = 'cashrefund' THEN TRUE
    ELSE FALSE
  END AS has_refund,
  CASE
    WHEN memo LIKE '%RMA%' THEN TRUE
    ELSE FALSE
  END AS is_exchange,
  item_detail.transaction_created_timestamp_pst,
  DATE(tran.trandate) AS transaction_date,
  CASE
    WHEN item_detail.full_status LIKE ANY(
      '%Closed',
      '%Voided',
      '%Undefined',
      '%Rejected',
      '%Unapproved',
      '%Not Deposited'
    ) THEN TRUE
    ELSE FALSE
  END AS status_flag_edw,
  DATE(tran.startdate) AS shipping_window_start_date,
  DATE(tran.enddate) AS shipping_window_end_date,
  item_detail.createdfrom,
  TRY_TO_NUMBER(tran.custbody_boomi_orderid) shopify_id,
  SUM(
    CASE
      WHEN item_detail.item_type = 'InvtPart' THEN item_detail.total_quantity
      ELSE 0
    END
  ) over (
    PARTITION BY
      item_detail.order_id_edw,
      item_detail.transaction_id_ns
  ) order_line_quantity,
  la.net_amount AS order_line_amount,
  number.trackingnumber tracking_number,
  FIRST_VALUE(item_detail.location IGNORE NULLS) over (
    PARTITION BY
      item_detail.order_id_edw,
      item_detail.transaction_id_ns
    ORDER BY
      item_detail.product_id_edw
  ) location
FROM
  fact.order_item_detail item_detail
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = item_detail.transaction_id_ns
  LEFT OUTER JOIN dim.channel channel ON channel.channel_id_ns = tran.cseg7
  LEFT OUTER JOIN netsuite.customer customer ON customer.id = tran.entity
  LEFT OUTER JOIN netsuite.trackingnumbermap map ON map.transaction = item_detail.transaction_id_ns
  LEFT OUTER JOIN netsuite.trackingnumber number ON number.id = map.trackingnumber
  LEFT OUTER JOIN line_amount la ON item_detail.transaction_id_ns = la.transaction_id_ns
WHERE
  item_detail.record_type IN (
    'cashsale',
    'itemfulfillment',
    'salesorder',
    'cashrefund',
    'invoice'
  )