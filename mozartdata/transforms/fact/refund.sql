 WITH
  refunds AS
    (
      SELECT
        ol.order_id_edw
      , ol.order_id_ns
      , ol.channel
      , ol.transaction_id_ns
      , ol.transaction_number_ns
      , ol.customer_id_ns
      , ol.transaction_created_timestamp_pst
      , ol.transaction_date AS refund_date
      , ol.amount_revenue
      , ol.amount_product
      , ol.amount_refunded
      , ol.amount_tax
      , ol.amount_paid
      FROM
        fact.order_line ol
      WHERE
        record_type = 'cashrefund'
      )
SELECT
  r.order_id_edw
, r.order_id_ns
, r.channel
, r.transaction_id_ns
, r.transaction_number_ns
, r.transaction_created_timestamp_pst
, r.customer_id_ns
, o.sold_date as order_sold_date
, date_trunc(month,o.sold_date) as order_sold_month
, r.refund_date
, date_trunc(month,r.refund_date) as refund_month
, r.amount_revenue
, r.amount_product
, r.amount_refunded
, r.amount_tax
, r.amount_paid
FROM
  refunds                         as r
LEFT JOIN
    bridge.orders                 as o
    ON
    r.order_id_edw = agg.order_id_edw