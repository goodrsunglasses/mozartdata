SELECT
    gt.account_number
  , gt.posting_period
  , ap.period_end_date
  , gt.channel
  , gt.transaction_number_ns
  , gt.record_type
  , p.sku
  , p.display_name
  ,tranline.accountinglinetype
  , SUM(gt.net_amount) total_cogs
  , SUM(coalesce(tranline.quantity,0)) quantity
  , tranline.rate unit_cogs
  , case when p.sku is null or SUM(coalesce(tranline.quantity,0)) = 0 then 'Bulk Update' else 'SKU Cogs' end as transaction_type
  FROM
    fact.gl_transaction gt
    LEFT JOIN
      dim.accounting_period ap
      on gt.posting_period = ap.posting_period
    LEFT JOIN
      dim.product p
      ON gt.item_id_ns = p.product_id_edw
    LEFT OUTER JOIN
      netsuite.transactionline tranline
      ON tranline.transaction = gt.transaction_id_ns
      AND tranline.id = gt.transaction_line_id_ns
      AND tranline.item = gt.item_id_ns
      AND tranline.mainline = 'F'
      AND tranline.accountinglinetype in ('COGS','CUSTOMERRETURNVARIANCE')
      AND tranline.iscogs = 'T'
      AND (tranline._FIVETRAN_DELETED = false or tranline._FIVETRAN_DELETED is null)
  WHERE
      gt.posting_flag
  AND gt.account_number = 5000
  GROUP BY
    ALL
   HAVING (SUM(gt.net_amount) != 0 or SUM(tranline.quantity) != 0)