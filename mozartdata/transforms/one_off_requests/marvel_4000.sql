with fulfillment as 
  (
    SELECT
      order_id_edw
    , country
    FROM
      fact.fulfillment
    qualify row_number() over (partition by order_id_edw order by ship_date asc) = 1
  ),
customers as 
  (
    SELECT
      customer_id_edw
    , customer_name
    FROM
      fact.customer_ns_map
    qualify row_number() over (partition by customer_id_edw order by customer_id_edw asc) = 1
  )
SELECT
  gl.posting_period,
  gl.account_number,
  channel,
  gl.product_id_edw,
  p.display_name,
  transaction_date,
  transaction_id_ns,
  transaction_line_id_ns,
  p.family,
  p.collection,
  oi.quantity_sold,
  net_amount,
  --- discount,
  --- credit reason,
  --- exchnage rate,
  gl.customer_id_edw,
  c.customer_name,
  f.country
FROM
  fact.gl_transaction gl
  left join dim.product p on gl.item_id_ns = p.item_id_ns
  left join fact.order_item oi on oi.order_id_edw = gl.order_id_edw and oi.sku = gl.product_id_edw
  left join fulfillment f on f.order_id_edw = gl.order_id_edw 
  left join customers c on c.customer_id_edw = gl.customer_id_edw
where 
  gl.account_number = 4000
  and posting_flag 
  and right(posting_period,4) in (2024, 2023, 2022, 2021) 
group by all