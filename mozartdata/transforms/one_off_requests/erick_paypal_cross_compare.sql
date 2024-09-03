SELECT
  pay.id AS paypal_id,
  pay.initiation_date,
  pay.updated_date,
  pay.invoice_id,
  tran.recordtype,
  pay.currency_code,
  tran.tranid,
  tran.custbody_goodr_shopify_order,
  tranline.netamount AS netsuite_amount,
  pay.amount AS paypal_amount,
  round(abs(pay.amount) - abs(tranline.netamount), 2) AS abs_diff
FROM
  paypal.transaction pay
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.memo = pay.id
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = tranline.transaction
WHERE
  tranline.id = 0
  AND tran.recordtype IN ('cashsale', 'cashrefund', 'invoice')
  AND abs_diff != 0
  AND date(tranline._fivetran_synced) > '2024-06-01'