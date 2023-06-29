SELECT 
  transactions.ns_transaction_id,
  transactions.ns_cust_id,
  customers.ns_altname
  
FROM dim.transactions transactions
left outer join dim.customers customers on customers.ns_cust_id = transactions.ns_cust_id