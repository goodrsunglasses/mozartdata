SELECT
  gl.posting_period,
  gl.account_number,
  channel,
  gl.product_id_edw,
  p.display_name,
  transaction_date,
  transaction_id_ns,
  p.family,
  p.collection,
  oi.quantity_sold,
  gl.net_amount,
  --- discount,
  --- credit reason,
  --- exchnage rate,
  gl.customer_id_edw,
  c.customer_name,
  f.country
FROM
  fact.gl_transaction gl
  left join dim.product p on gl.item_id_ns = p.item_id_ns
  left join fact.order_item oi on oi.order_id_edw = gl.order_id_edw and oi.product_id_edw = gl.product_id_edw
  left join fact.fulfillment f on f.order_id_edw = gl.order_id_edw 
  left join fact.customer_ns_map c on c.customer_id_edw = gl.customer_id_edw
where 
  gl.account_number = 4000
  and posting_flag 
  and transaction_date between '2022-01-01' and '2024-10-31'
group by all