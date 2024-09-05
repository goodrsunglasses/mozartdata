SELECT 
   channel,
   sum(net_amount) previous_week
  FROM 
  (
   
   SELECT * FROM fact.gl_transaction
  where channel in ('Amazon','Specialty CAN','Specialty','Cabana','Global','goodr.ca','Goodr.com','Key Accounts','Prescription','Key Account CAN')
  and transaction_date between date_trunc(week,dateadd(day,-7,current_date())) and  dateadd(day,6,date_trunc(week,dateadd(day,-7,current_date())))
  and account_number >= 4000 and account_number < 5000 
   and posting_flag = true
   
   ) gl
group by 1