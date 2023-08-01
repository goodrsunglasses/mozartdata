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
--cte to grab all of the custom item data that lives on other random tables
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
  tran.NS_transaction_ID, --netsuite transaction id
  tran.ns_transaction_type, --netsuite transaction type 
  tran.ns_cust_id, --netsuite custumer id
  tran.ns_channel, --netsuite transaction channel
  tran.ns_trandate,--netsuite transaction date
  CASE --case when to just fill in some nulls for better readability
    WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
    WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
    WHEN tranline.itemtype = 'Discount' THEN 'Discount'
    ELSE item.displayname
  END AS display_name,
  CASE--case when to just fill in some nulls for better readability
    WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
    WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
    ELSE item.externalid
  END AS external_id,
  item.id AS item_id, --ns item id
  item_cust_fields.family, --ns item family
  item_cust_fields.class,--ns item class
  item_cust_fields.stage,--ns item stage
  -1 * tranline.quantity quantity, --quantity of item, multiplied by -1 because by default they count as deductions
  tranline.itemtype,--to be able to tell what item type it is, discount,tax,inventory, etc..
  tranline.rate,--flat rate of the item pre-discount
  -1 * tranline.netamount AS netamount--amount post discount, *-1 because by default they count as deductions
FROM
  dim.transactions tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.ns_id
  LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
  LEFT OUTER JOIN item_cust_fields ON item.id = item_cust_fields.id
ORDER BY
  ns_transaction_id desc