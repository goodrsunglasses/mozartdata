WITH
  netsuite_data AS (
    SELECT
      tranline.transaction,
      tran.custbody_merch_auth_id merch_auth,
      tran.recordtype,
      tran.tranid,
      tranline.netamount,
      tran.custbody_goodr_shopify_order AS order_id_edw
    FROM
      netsuite.transactionline tranline
      LEFT OUTER JOIN netsuite.transaction tran ON tran.id = tranline.transaction
    WHERE
      tranline.id = 0
      AND custbody_merch_auth_id IS NOT NULL
      AND recordtype IN ('cashsale', 'cashrefund')
  ),
  braintree_data AS (
    SELECT
      id,
    TYPE,
    date(disbursement_date) disbursement_date,
    amount,
    disbursement_settlement_amount
    FROM
      braintree.transaction
  )
SELECT
  disbursement_date,
TYPE,
transaction AS netsuite_transaction_id,
tranid,
recordtype,
id AS braintree_transaction_id,
CASE
  WHEN order_id_edw LIKE '%-CA%' THEN amount
  ELSE disbursement_settlement_amount
END AS presentment_amount,
order_id_edw,
netamount AS netsuite_netamount,
round(abs(presentment_amount) - abs(netamount), 2) AS difference
FROM
  braintree_data
  LEFT OUTER JOIN netsuite_data ON netsuite_data.merch_auth = braintree_data.id
WHERE
  abs(presentment_amount) != abs(netamount)
  AND disbursement_date > DATEADD(MONTH, -2, CURRENT_DATE)
ORDER BY
TYPE asc