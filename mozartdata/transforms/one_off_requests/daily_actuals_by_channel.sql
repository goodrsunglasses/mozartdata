SELECT 
  DATE(transaction_date) as txn_date,
  channel,
  sum(net_amount) as revenue_actual
  
  

from fact.gl_transaction gl
where gl.transaction_date >= '2024-01-01'
  and gl.posting_flag = true
  and gl.account_number >= 4000 and gl.account_number < 5000
group by   DATE(transaction_date),
  channel
order by 1,2