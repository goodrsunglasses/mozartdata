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

SELECT
  transaction.tranid AS NS_transaction_ID,
  transaction.trandate as ns_trandate,
  transaction.recordtype AS ns_transaction_type,
  transaction.entity AS ns_cust_id,
  transaction.id AS NS_ID,
  transactionline.netamount as revenue,
  -- shopifyid
  -- shopifycustid
  -- shopifytranid
  channel.name AS ns_channel

FROM
  netsuite.transaction transaction
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON transaction.cseg7 = channel.id
  LEFT OUTER JOIN netsuite.transactionline transactionline ON transaction.id = transactionline.transaction
WHERE
  revenue>0 
  and transactionline.accountinglinetype is null --did this because it needs to be not a gift card since theyre > 0 
  and ns_transaction_id is not null -- Filtering out all the seemingly null transactions we have
  and ns_transaction_type in ('salesorder','cashsale','invoice')
order by ns_transaction_id desc