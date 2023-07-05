SELECT 
  transactions.ns_transaction_id,
  transactions.ns_cust_id,
  customers.ns_altname,
  transactions.ns_transaction_type,
  customers.ns_altname,
  transactions.ns_trandate,
  transactions.ns_channel,
  ---ns_margin
  ---ns_revenue_date
  transactions.ns_rate
  
FROM dim.transactions transactions
left outer join dim.customers customers on customers.ns_cust_id = transactions.ns_cust_id