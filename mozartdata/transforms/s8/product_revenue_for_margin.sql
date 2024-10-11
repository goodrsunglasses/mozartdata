/*
Questions for PR:
- Should we exclude 4050 (shipping fee income)? I don't believe we include shipping expense into cogs so this would inflate revenue and margin

Notes:
  AccountingLineType (Account_Numbers)
  INCOME (4000, 4050, 4110, 4210, 4220, 4225) 
  PAYMENT (4210)
  DISCOUNT (4110)
  4000 sales
  4050 shipping fee income
  4110 returns, discounts allowances: discounts
  4210 returns, discounts allowances: returns/refunds
  4220 returns, discounts allowances: defectives
  4225 returns, discounts allowances: chargebacks
*/


SELECT distinct
    gt.account_number
  , gt.posting_period
  , ap.period_end_date
  , gt.channel
  , gt.transaction_number_ns
  , gt.record_type
  , p.sku
  , p.item_id_ns
  , p.display_name
  , tranline.accountinglinetype
  , SUM(gt.net_amount) total_revenue
  , -SUM(coalesce(tranline.quantity,0)) quantity
--  , tranline.rate unit_cogs
  , case when p.sku is null or SUM(coalesce(tranline.quantity,0)) = 0 then 'Bulk Update' else 'SKU Revenue' end as transaction_type
  FROM
    fact.gl_transaction gt
    LEFT JOIN
      dim.accounting_period ap
      on gt.posting_period = ap.posting_period
    LEFT JOIN
      dim.product p
      ON gt.product_id_edw = p.product_id_edw
    LEFT OUTER JOIN
      netsuite.transactionline tranline
      ON tranline.transaction = gt.transaction_id_ns
      AND tranline.id = gt.transaction_line_id_ns
      AND tranline.item = gt.item_id_ns
      AND tranline.mainline = 'F'
      AND tranline.accountinglinetype = 'INCOME'
      AND (tranline._FIVETRAN_DELETED = false or tranline._FIVETRAN_DELETED is null)
  WHERE
      gt.posting_flag
  AND gt.account_number = '4000'
  GROUP BY
    ALL
   HAVING (SUM(gt.net_amount) != 0 or SUM(tranline.quantity) != 0)