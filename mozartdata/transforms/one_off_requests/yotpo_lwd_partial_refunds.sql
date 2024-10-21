with labor_day as
  (
  SELECT
    da.order_id,
    da.title as code,
    sum(amount) as amount
  FROM
    shopify.discount_application da
 left join
    shopify.order_line ol
  on da.order_id =ol.order_id
  left join
    shopify.discount_allocation dl
  on ol.id = dl.order_line_id
   and da.index = dl.discount_application_index
  WHERE
    da.title like '%24 LDW 20% OFF'
  group by 1,2
  ),
    yotpo as
  (
      SELECT
      da.order_id,
      da.code AS code,
      sum(value) AS amount
    FROM
      shopify.discount_application da
    WHERE
      da.code like '%YOTPO%'
    GROUP BY 1,2
  ),
 combined as (
SELECT
 ld.order_id
, ld.code labor_day_code
, ld.amount labor_day_discount_shopify
, y.code yotpo_code
, y.amount yotpot_discount_shopify
FROM
  labor_day ld
INNER JOIN
  yotpo y
  on ld.order_id = y.order_id

) ,
  partial_refunds as (
    SELECT
    pr.*
  , round(pr.amount_2430-abs(pr.amount_4210)*.2 ,2)as yotpo_amt
  FROM
    (
  SELECT
    o.name as order_id_edw
  , date(CONVERT_TIMEZONE('America/Los_Angeles', o.created_at)) shopify_order_date
  , c.* 
  --, gt.account_number
  , gt.posting_period
  , gt.transaction_date
  , gt.transaction_number_ns
  ,  SUM(case when gt.account_number = 2430  then gt.net_amount else 0 end) amount_2430
  , SUM(case when gt.account_number = 4210  then gt.net_amount else 0 end) amount_4210
  FROM
    combined c
  inner join
    shopify."ORDER" o
  ON c.order_id = o.id
  left join
    fact.gl_transaction gt
  on o.name = gt.order_id_edw
  where --c.order_id= 5352731574330
  gt.posting_flag
  -- and gt.transaction_number_ns = 'CR0132052'
  and gt.account_number in (2430,4210)
  group by all
  ) pr
  )
select
  pr.order_id_edw
  , pr.shopify_order_date
  , pr.order_id
  , pr.labor_day_code
  , pr.labor_day_discount_shopify
  , pr.yotpo_code
  , pr.yotpot_discount_shopify
  , pr.posting_period
  , pr.transaction_date
  , pr.transaction_number_ns
  , pr.amount_2430 as net_amount
  , case when transaction_number_ns like 'CR%' then pr.yotpo_amt  else null end as partial_refund_yotpo
from
  partial_refunds pr