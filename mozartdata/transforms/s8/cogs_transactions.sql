with cogs as (
  SELECT
    gt.account_number
  , gt.posting_period
  , gt.channel
  , gt.transaction_number_ns
  , gt.record_type
  , p.sku
  ,tranline.accountinglinetype
  , SUM(gt.net_amount) total_cogs
  , SUM(coalesce(tranline.quantity,0)) quantity
  , tranline.rate unit_cogs
  FROM
    fact.gl_transaction gt
    LEFT JOIN
      dim.product p
      ON gt.item_id_ns = p.product_id_edw
    LEFT OUTER JOIN
      netsuite.transactionline tranline
      ON concat(tranline.transaction,'_',tranline.id) = gt.transaction_line_id
      AND tranline.item = gt.item_id_ns
      AND tranline.accountinglinetype in ('COGS','CUSTOMERRETURNVARIANCE')
      AND tranline.quantity is not null
  WHERE
      gt.posting_flag
  AND gt.account_number = 5000
  AND tranline.mainline = 'F'
  AND tranline.accountinglinetype in ('COGS','CUSTOMERRETURNVARIANCE')
  AND tranline.iscogs = 'T'
  AND (tranline._FIVETRAN_DELETED = false or tranline._FIVETRAN_DELETED is null)
  AND tranline.quantity is not null
  GROUP BY
    ALL
  )
select * from cogs