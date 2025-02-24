select tal.* 
      from
      netsuite.transactionaccountingline tal
    inner join
      netsuite.transaction tran
      on tal.transaction = tran.id
    inner join
      dim.accounting_period ap
      on tran.postingperiod = ap.accounting_period_id
where tal.posting = 'T'
  and ap.posting_period = 'Jan 2025' 
and tal.lastmodifieddate >= '2024-02-13 12:00:00'
order by lastmodifieddate desc