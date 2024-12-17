/*
  Purpose: To show totals for refunds without returns to refunds with returns.
  Requested by: Sara Levi
  Primary Key: None
  Create date: 2024-12-17
*/ 

SELECT 
  CASE
    when courier_pretty = 'No Send Back'
      then 'refunds without returns'
    when courier_pretty = 'USPS' 
      then 'refunds with returns'
  end as return_type
  , sum(quantity) as total_refunded_items
  , round(sum(shopify_total_refund_amount), 2) as total_refund_amount_with_tax
  , round(sum(shopify_total_refund_amount - shopify_refunded_tax), 2) as total_refund_amount_without_tax
FROM 
  google_sheets.parcellab_returns
WHERE
  compensation_method != 'exchange'
group by
  courier_pretty