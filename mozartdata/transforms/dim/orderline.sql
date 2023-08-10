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
  salesorder_line AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.entity,
      channel.name AS channel,
      tran.trandate,
      CASE --case when to just fill in some nulls for better readability
        WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
        WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
        WHEN tranline.itemtype = 'Discount' THEN 'Discount'
        ELSE product.displayname
      END AS display_name,
      CASE --case when to just fill in some nulls for better readability
        WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
        WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
        ELSE product.sku
      END AS external_id,
      tranline.netamount
    FROM
      netsuite.transaction tran
      LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
      LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
      LEFT OUTER JOIN dim.product product ON product.ns_item_id = tranline.item
    WHERE
      tran.recordtype = 'salesorder'
      AND tranline.linesequencenumber != 0
  )
SELECT
  tran.NS_transaction_ID, --netsuite transaction id
  tran.ns_transaction_type, --netsuite transaction type 
  tran.ns_cust_id, --netsuite custumer id
  tran.ns_channel, --netsuite transaction channel
  tran.ns_trandate, --netsuite transaction date
  CASE --case when to just fill in some nulls for better readability
    WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
    WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
    WHEN tranline.itemtype = 'Discount' THEN 'Discount'
    ELSE item.displayname
  END AS display_name,
  CASE --case when to just fill in some nulls for better readability
    WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
    WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
    ELSE item.externalid
  END AS external_id,
  item.id AS item_id, --ns item id
  item_cust_fields.family, --ns item family
  item_cust_fields.class, --ns item class
  item_cust_fields.stage, --ns item stage
  -1 * tranline.quantity quantity, --quantity of item, multiplied by -1 because by default they count as deductions
  tranline.itemtype, --to be able to tell what item type it is, discount,tax,inventory, etc..
  tranline.rate, --flat rate of the item pre-discount
  -1 * tranline.netamount AS netamount --amount post discount, *-1 because by default they count as deductions
FROM
ORDER BY
  ns_transaction_id desc