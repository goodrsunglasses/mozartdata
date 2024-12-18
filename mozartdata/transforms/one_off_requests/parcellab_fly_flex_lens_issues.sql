SELECT 
  ret.created as created_timestamp
  , ret.created_date
  , ret.order_no
  , prod.sku
  , prod.display_name
  , ret.quantity
  , ret.return_reason_code
  , ret.return_reason_description
  , ret.return_customer_comment
  , ret.compensation_method
  , ret.shopify_total_refund_amount
  , ret.email
  , ret.client as store
  ,ret.tracking_number
  , ret.date_in_transit
  , ret.date_delivered
FROM 
  google_sheets.parcellab_returns as ret
inner join 
  dim.product as prod
  on
    ret.article_no = prod.sku
where
  lower(prod.collection) in (
    'fly g'
    , 'flex g'
  )
  and ret.return_reason_code like 'len%'
order by 
  ret.created asc