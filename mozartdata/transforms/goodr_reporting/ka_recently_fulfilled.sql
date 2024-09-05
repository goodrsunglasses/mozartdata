SELECT
  ol.order_id_edw,
  ol.transaction_number_ns,
  ol.transaction_created_timestamp_pst,
  ol.transaction_date,
  c.customer_id_ns as ns_customer_id,
  c.customer_name
FROM
  fact.order_line ol
  LEFT JOIN fact.customer_ns_map c on c.customer_id_ns = ol.customer_id_ns
WHERE
  ol.channel = 'Key Accounts'
  and record_type = 'itemfulfillment'
  and transaction_status_ns = 'Item Fulfillment : Shipped'
  and transaction_created_timestamp_pst >= DATEADD(DAY, -30, CURRENT_DATE)
ORDER BY transaction_created_timestamp_pst desc