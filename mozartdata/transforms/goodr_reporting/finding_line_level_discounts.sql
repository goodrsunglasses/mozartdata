------- step 1: find the discount title
/*
GOODR CAN 
select * from  goodr_canada_shopify.discount_application 
order by order_id desc 

GOODR.COM 
select * from  shopify.discount_application 
order by order_id desc 
*/
------ step 2: update the titles in the shopify ctes where clauses
with canada as (
  SELECT
    o.*,
    da.order_id,
    da.title as code,
    sum(amount) as promo_amount
  FROM
    goodr_canada_shopify.discount_application da
 left join
    goodr_canada_shopify.order_line ol
  on da.order_id =ol.order_id
  left join
    goodr_canada_shopify.discount_allocation dl
  on ol.id = dl.order_line_id
   and da.index = dl.discount_application_index
  left join goodr_canada_shopify."ORDER" o
    on da.order_id = o.id
  WHERE
    da.title  ilike '%Pour%'                                ---- update title here (double check above it works, titles are captured weird)
  group by all  
)
, us as (
  SELECT
    o.*,
    da.order_id,
    da.title as code,
    sum(amount) as promo_amount
  FROM
    shopify.discount_application da
 left join
    shopify.order_line ol
  on da.order_id =ol.order_id
  left join
    shopify.discount_allocation dl
  on ol.id = dl.order_line_id
   and da.index = dl.discount_application_index
  left join shopify."ORDER" o
    on da.order_id = o.id
  WHERE
    da.title  ilike '%Pour%'                                ---- update title here (double check above it works, titles are captured weird)
  group by all
)
select * from canada
union all 
select * from us