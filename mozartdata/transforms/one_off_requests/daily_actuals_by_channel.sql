SELECT 
  DATE(transaction_date) as txn_date,
  channel,
  sum(net_amount) as revenue_actual
  
  

from fact.gl_transaction
where transaction_date >= '2024-01-01'
  and posting_flag = true
  and account_number >= 4000 and account_number < 50000
group by 1 ,2
order by 1,2