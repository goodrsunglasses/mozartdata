SELECT
  ol.*,
  c.customer_id_ns as ns_customer_id,
  c.customer_name
FROM
  fact.order_line ol
  LEFT JOIN fact.customer_ns_map c on c.customer_internal_id_ns = ol.customer_id_ns
WHERE
  ol.channel = 'Key Account'
  and record_type = 'itemfulfillment'
  and transaction_status_ns = 'Item Fulfillment : Shipped'
  and transaction_created_timestamp_pst >= DATEADD(DAY, -30, CURRENT_DATE)
ORDER BY transaction_created_timestamp_pst desc