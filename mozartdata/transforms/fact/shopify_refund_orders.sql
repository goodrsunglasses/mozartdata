with adjustments as
  (
    SELECT
      order_id_shopify,
      ORDER_ID_EDW,
      store,
       array_agg(reason) adjustment_reason_array,--SADLY THIS HAS TO BE AN ARRAY BECAUSE WE HAVE MULTIPLE ADJUSTMENTS PER ORDER ¯\_(ツ)_/¯
       array_agg(note) refund_note_array,
       sum(amount_adjustment)  as amount_adjustment,
       sum(amount_adjustment_tax) as amount_adjustment_tax,
       sum(amount_adjustment_total) as amount_adjustment_total
       from
         fact.shopify_refund_order_adjustments
       group by all
  ),
  line as
    (
      SELECT order_id_shopify,
       ORDER_ID_EDW,
       store,
       sum(QUANTITY_REFUND_LINE)  as quantity_refund_line,
      sum(amount_refund_line_subtotal) as amount_refund_line_subtotal,
       sum(amount_refund_line_tax) as amount_refund_line_tax,
       sum(amount_refund_line_total) as amount_refund_line_total
FROM fact.shopify_refund_order_item_detail od
GROUP BY ALL

    )
SELECT l.order_id_shopify,
       l.ORDER_ID_EDW,
       l.store,
       a.adjustment_reason_array,--SADLY THIS HAS TO BE AN ARRAY BECAUSE WE HAVE MULTIPLE ADJUSTMENTS PER ORDER ¯\_(ツ)_/¯
       a.refund_note_array,
       l.quantity_refund_line,

       l.amount_refund_line_subtotal,
       l.amount_refund_line_tax,
       l.amount_refund_line_total,
       l.amount_refund_line_subtotal+a.amount_adjustment  as amount_refund_subtotal,
       l.amount_refund_line_tax+a.amount_adjustment_tax       as amount_refund_tax,
       l.amount_refund_line_total+a.amount_adjustment_total     as amount_refund_total
FROM line l
LEFT JOIN
    adjustments a
    on l.order_id_shopify = a.order_id_shopify and l.store = a.store
GROUP BY ALL