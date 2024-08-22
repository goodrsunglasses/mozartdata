SELECT
  pay.id as paypal_id,
  pay.initiation_date,
  pay.updated_date,
  pay.currency_code,
  pay.amount as paypal_amount,
  pay.invoice_id,
  tran.custbody_goodr_shopify_order,
  tran.tranid,
  tran.recordtype,
  tranline.netamount as netsuite_amount,
  round(abs(pay.amount)-abs(tranline.netamount),2) as abs_diff
FROM
  paypal.transaction pay
  left outer join netsuite.transactionline tranline on tranline.memo=pay.id
  left outer join netsuite.transaction tran on tran.id = tranline.transaction 
WHERE
  tranline.id = 0
  AND tran.recordtype IN ('cashsale', 'cashrefund', 'invoice')
  and abs_diff != 0 
  and date(tranline._fivetran_synced)> '2024-06-01'