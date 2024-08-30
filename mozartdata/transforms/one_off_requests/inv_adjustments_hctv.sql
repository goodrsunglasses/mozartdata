SELECT
  gt.transaction_line_id,
  gt.transaction_id_ns,
  gt.transaction_number_ns,
  gt.record_type,
  gt.channel,
  gt.transaction_date,
  gt.item_id_ns,
  gt.memo,
  gt.posting_period,
  p.sku,
  p.display_name,
--  gt.quantity,
--  period,
  sum(gt.net_amount) net_amount,
  gt.account_number,
  ga.account_display_name
FROM
  fact.gl_transaction gt
left join 
    dim.product p on p.item_id_ns = gt.item_id_ns
left join 
  dim.gl_account ga on gt.account_id_ns = ga.account_id_ns
WHERE
  (gt.record_type = 'inventoryadjustment' or transaction_number_ns = 'JE0025640')
  AND gt.posting_flag
  and (posting_period like '%22' or posting_period like '%23' or posting_period in ('Jun 24', 'Jul 24'))
GROUP BY
 all