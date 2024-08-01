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
  ),
  braintree_data AS (
    SELECT
      id,
    TYPE,
    date(disbursement_date) disbursement_date,
    disbursement_settlement_amount
    FROM
      braintree.transaction
  )
SELECT
  id AS braintree_transaction_id,
TYPE,
disbursement_date,
disbursement_settlement_amount,
transaction AS netsuite_transaction_id,
tranid,
order_id_edw,
recordtype,
netamount as netsuite_netamount,
round(disbursement_settlement_amount - netamount, 2) AS difference
FROM
  braintree_data
  LEFT OUTER JOIN netsuite_data ON netsuite_data.merch_auth = braintree_data.id
WHERE
  disbursement_settlement_amount != netamount
ORDER BY
TYPE asc