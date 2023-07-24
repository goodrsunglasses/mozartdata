-- purpose:
-- One row per transaction.
-- This transform creates the transactions dimension by combining data from netsuite and shopify.
-- aliases: 
-- ns = netsuite
-- shop = shopify
-- cust = customer
-- with revenue as (
-- select * from netsuite.transactionline where transaction = 13356008
-- )
-- select 
--   count(NS_transaction_ID) as countran
--   from(
SELECT
  transaction.tranid AS NS_transaction_ID,
  transaction.trandate AS ns_trandate,
  transaction.recordtype AS ns_transaction_type,
  transaction.entity AS ns_cust_id,
  transaction.id AS NS_ID,
  transactionline.netamount AS revenue,
  -- shopifyid
  -- shopifycustid
  -- shopifytranid
  channel.name AS ns_channel
FROM
  netsuite.transaction transaction
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON transaction.cseg7 = channel.id
  LEFT OUTER JOIN netsuite.transactionline transactionline ON transaction.id = transactionline.transaction
WHERE
  transactionline.linesequencenumber = 0 --as per joshas recc, use the 0th line for the netamount that ends up being the total
  -- and transactionline.accountinglinetype is null --leave it commented out until INV issue is resolved
  AND ns_transaction_id is not null -- Filtering out all the seemingly null transactions we have
  AND ns_transaction_type IN ('salesorder', 'cashsale', 'invoice')
ORDER BY
  ns_transaction_id desc
-- )