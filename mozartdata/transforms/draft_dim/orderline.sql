/*
purpose:
Variable amount rows per line item in a given order


*/
--salesorder line item cte
WITH
  salesorder_line AS (
    SELECT
      tran.custbody_goodr_shopify_order order_num,
      tran.entity AS ns_cust_id,
      channel.name AS channel,
      tran.trandate,
      -- CASE --case when to just fill in some nulls for better readability
      --   WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
      --   WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
      --   WHEN tranline.itemtype = 'TaxGroup' THEN 'Tax Group'
      --   WHEN tranline.itemtype = 'Discount' THEN 'Discount'
      --   ELSE product.displayname
      -- END AS display_name,
      -- CASE --case when to just fill in some nulls for better readability
      --   WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
      --   WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
      --   WHEN tranline.itemtype = 'TaxGroup' THEN 'Tax Group'
      --   ELSE product.sku
      -- END AS external_id,
      tranline.item,
      -1 * tranline.netamount AS netamount, --netamount of item, multiplied by -1 because by default they count as deductions
      tranline.rate, --flat rate of the item pre-discount
      -1 * tranline.quantity quantity, --quantity of item, multiplied by -1 because by default they count as deductions
      netamount * quantity AS total_netatmount, --multiplying the netamount by the quantity to get a total that will hypothetically be used
      tranline.itemtype
    FROM
      netsuite.transaction tran
      LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
      LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
    WHERE
      tran.recordtype = 'salesorder'
      AND tranline.linesequencenumber != 0
  )
SELECT
  *
FROM
  salesorder_line
ORDER BY
  order_num asc