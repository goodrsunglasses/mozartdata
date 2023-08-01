/*
purpose:
One row per sku per transaction.
This transform creates the transactionline dimension by combining data from netsuite and shopify.

joins: 

aliases: 
ns = netsuite
shop = shopify
tran = transaction
*/
WITH
  item_cust_fields AS (
    SELECT
      item.id,
      class.name AS class,
      family.name AS family,
      stage.name AS stage
    FROM
      netsuite.item item
      LEFT OUTER JOIN netsuite.CUSTOMLIST_PSGSS_MERC_CLASS class ON item.custitem_psgss_merc_class = class.id
      LEFT OUTER JOIN netsuite.CUSTOMLIST894 family ON item.custitem4 = family.id
      LEFT OUTER JOIN netsuite.CUSTOMLIST896 stage ON stage.id = item.custitem6
  )
SELECT
  tran.NS_transaction_ID,
  tran.ns_transaction_type,
  tran.ns_cust_id,
  tran.ns_channel,
  tran.ns_trandate,
  CASE
    WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
    WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
    WHEN tranline.itemtype = 'Discount' THEN 'Discount'
    ELSE item.displayname
  END AS display_name,
  CASE
    WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
    WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
    ELSE item.externalid
  END AS external_id,
  item.id AS item_id,
  item_cust_fields.family,
  item_cust_fields.class,
  item_cust_fields.stage,
  -1 * tranline.quantity quantity,
  tranline.itemtype,
  tranline.rate,
  -1*tranline.netamount as netamount
FROM
  dim.transactions tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.ns_id
  LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
  LEFT OUTER JOIN item_cust_fields ON item.id = item_cust_fields.id
WHERE
  tranline.transaction = 1049845
  AND tranline.item