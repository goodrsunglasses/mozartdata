SELECT
  custbody_goodr_shopify_order AS order_id_edw,
  recordtype,
  id,
  CONVERT_TIMEZONE('America/Los_Angeles', createddate) AS timestamp_transaction_PST
FROM
  netsuite.transaction tran
WHERE
  recordtype IN (
    'invoice',
    'cashsale',
    'salesorder',
    'itemfulfillment',
    'cashrefund'
  )
  AND order_id_edw = 'G1863077'