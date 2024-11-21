SELECT 
 
 transaction_date,
  SUM(net_amount) as revenue

  FROM fact.gl_transaction gl
where  posting_flag = true and gl.account_number like '4%'
  and channel = 'Goodr.com'
  --and lower(channel) not in ('goodrwill','specialty can','goodr.ca') --and gl.account_number in (4210,4225,4220)
group by 1
order by 1