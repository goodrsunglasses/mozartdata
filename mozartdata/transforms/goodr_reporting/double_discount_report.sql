------- step 1: find the discount title
/*
select * from  shopify.discount_application 
order by order_id desc 
*/
------ step 2: update the title in the promo cte where clause
with promo as
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
    da.title  ilike '%Pour%'                                ---- update title here (double check above it works, titles are captured weird)
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
 p.order_id
, p.code promo_code
, p.amount promo_discount_shopify
, y.code yotpo_code
, y.amount yotpot_discount_shopify
FROM
  promo p
INNER JOIN
  yotpo y
  on p.order_id = y.order_id

) 
  SELECT
    o.name as order_id_edw
  , date(CONVERT_TIMEZONE('America/Los_Angeles', o.created_at)) shopify_order_date
  ,c.* 
  , gt.account_number
  , gt.posting_period
  , gt.transaction_date
  , gt.transaction_number_ns
  , gt.net_amount
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
  and gt.account_number = 2430