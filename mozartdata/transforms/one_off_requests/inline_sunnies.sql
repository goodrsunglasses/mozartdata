--dim.product where family = 'INLINE' and merchandise_department = 'SUNGLASSES'
with customer_orders as
(
  SELECT
    o.order_id_edw
  , o.customer_id_edw
  , o.booked_date
  , row_number() over (partition by o.customer_id_edw order by o.sold_date) customer_order_number
  FROM
    fact.orders o
  WHERE
    o.channel = 'Goodr.com' and o.order_id_edw like 'G%'
  and o.customer_id_edw is not null
),
baskets as
(
  SELECT
    oi.order_id_edw
  , p.sku
  , p.display_name
  , p.family
  , p.merchandise_class
  , p.design_tier
  , sum(oi.quantity_booked) quantity_booked
  , sum(oi.quantity_sold) quantity_sold
  FROM
    fact.order_item oi
  INNER JOIN
    fact.orders o
    on oi.order_id_edw = o.order_id_edw
  INNER JOIN
    dim.product p
    on oi.product_id_edw = p.product_id_edw
  WHERE
    p.merchandise_department = 'SUNGLASSES'
  and o.channel = 'Goodr.com'
  and oi.order_id_edw like 'G%'
  GROUP BY
    oi.order_id_edw
  , p.sku
  , p.display_name
  , p.merchandise_class
  , p.family
  , p.design_tier
  ORDER BY
    oi.order_id_edw
),
baskets_agg as
(
  SELECT
    b1.order_id_edw
  , b1.sku
  , b1.display_name
  , b1.merchandise_class
  , b1.family
  , b1.design_tier
  , b1.quantity_booked sku_quantity_booked
  , sum(coalesce(b2.quantity_booked,0)) other_quantity_booked
  , b1.quantity_booked+sum(coalesce(b2.quantity_booked,0)) as total_order_quantity_booked
  , sum(case when b2.family = 'INLINE' then b2.quantity_booked else 0 end) inline_quantity
  , sum(case when b2.family = 'LICENSING' then b2.quantity_booked else 0 end) licensing_quantity
  , sum(case when b2.family = 'LIMITED EDITION' then b2.quantity_booked else 0 end) limited_edition_quantity
  , sum(case when b2.design_tier = 'STYLED' then b2.quantity_booked else 0 end) styled_quantity
  , sum(case when b2.design_tier = 'WILD' then b2.quantity_booked else 0 end) wild_quantity
  , sum(case when b2.design_tier = 'MILD' then b2.quantity_booked else 0 end) mild_quantity
  , sum(case when b2.merchandise_class = 'VRGS' then b2.quantity_booked else 0 end) vrgs_quantity
  , sum(case when b2.merchandise_class = 'OGS' then b2.quantity_booked else 0 end) ogs_quantity
  , sum(case when b2.merchandise_class = 'CIRCLE GS' then b2.quantity_booked else 0 end) circlegs_quantity
  , sum(case when b2.merchandise_class = 'RUNWAYS' then b2.quantity_booked else 0 end) runways_quantity
  , sum(case when b2.merchandise_class = 'SNOW G' then b2.quantity_booked else 0 end) snowgs_quantity
  , sum(case when b2.merchandise_class = 'WRAP GS' then b2.quantity_booked else 0 end) wrapgs_quantity
  , sum(case when b2.merchandise_class = 'PHGS' then b2.quantity_booked else 0 end) phgs_quantity
  , sum(case when b2.merchandise_class = 'BFGS' then b2.quantity_booked else 0 end) bfgs_quantity
  , sum(case when b2.merchandise_class = 'MACH GS' then b2.quantity_booked else 0 end) machgs_quantity
  , sum(case when b2.merchandise_class = 'LFGS' then b2.quantity_booked else 0 end) lfgs_quantity
  from
    baskets b1
  left join
    baskets b2
    on b1.order_id_edw = b2.order_id_edw
    and b1.sku != b2.sku
  group by
    b1.order_id_edw
  , b1.sku
  , b1.display_name
  , b1.merchandise_class
  , b1.family
  , b1.design_tier
  , b1.quantity_booked
)

SELECT
--   co.order_id_edw
-- , co.customer_id_edw
-- , booked_date
-- , co.customer_order_number
  ba.sku
, ba.display_name
, ba.merchandise_class
, ba.family
, ba.design_tier
, sum(case when co.customer_order_number = 1 then sku_quantity_booked else 0 end) first_order_sku_quantity_booked
, sum(case when co.customer_order_number = 2 then sku_quantity_booked else 0 end) second_order_sku_quantity_booked
, sum(case when co.customer_order_number = 3 then sku_quantity_booked else 0 end) third_order_sku_quantity_booked
, sum(case when co.customer_order_number > 3 then sku_quantity_booked else 0 end) three_plus_order_sku_quantity_booked
, sum(ba.sku_quantity_booked) sku_quantity_booked
, sum(ba.other_quantity_booked) other_quantity_booked
, sum(ba.total_order_quantity_booked) total_order_quantity_booked
, sum(ba.inline_quantity) inline_quantity
, sum(ba.licensing_quantity) licensing_quantity
, sum(ba.limited_edition_quantity) limited_edition_quantity
, sum(ba.styled_quantity) styled_quantity
, sum(ba.wild_quantity) wild_quantity
, sum(ba.mild_quantity) mild_quantity
, sum(ba.vrgs_quantity) vrgs_quantity
, sum(ba.ogs_quantity) ogs_quantity
, sum(ba.circlegs_quantity) circlegs_quantity
, sum(ba.runways_quantity) runways_quantity
, sum(ba.snowgs_quantity) snowgs_quantity
, sum(ba.wrapgs_quantity) wrapgs_quantity
, sum(ba.phgs_quantity) phgs_quantity
, sum(ba.bfgs_quantity) bfgs_quantity
, sum(ba.machgs_quantity) machgs_quantity
, sum(ba.lfgs_quantity) lfgs_quantity
from 
  customer_orders co
left join
  baskets_agg ba
  on co.order_id_edw = ba.order_id_edw
group by
--     co.order_id_edw
-- , co.customer_id_edw
-- , booked_date
-- , co.customer_order_number
 ba.sku
, ba.display_name
, ba.merchandise_class
, ba.family
, ba.design_tier
order by 
ba.sku