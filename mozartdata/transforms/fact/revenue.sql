SELECT 
  transactions.ns_transaction_id,
  transactions.ns_cust_id,
  customers.ns_cust_name,
  transactions.ns_transacation_type,
  customers.ns_altname,
  --- ns_transaction date
  transactions.ns_channel
  ---ns_margin
  ---ns_revenue_date
  --- amount
  
FROM dim.transactions transactions
left outer join dim.customers customers on customers.ns_cust_id = transactions.ns_cust_id