/*
This QC was performed on 2/24/2024 by Josha. So row counts/data profile is as of that day.
QC steps
1. update all of the draft_fact tables (staging.order_item_detail -> draft_fact.orders)
2. check row counts
3. profile the data
4. spot check
*/
/*
row count check -> we are seeing row count differences at the order_item_detail level which is concerning. Upon further analysis it is all "estimates" records
fact.order_item_detail
23076057
draft_fact.order_item_detail
23071859
staging.order_item_detail (difference is 8523)
23084580
fact.order_item
8589358
draft_fact.order_item
8518499
fact.order_line
6166584
draft_fact.order_line
6166172
fact.orders
1959446
draft_fact.orders
1960975
*/
SELECT
  'fact.order_item_detail' as table_name
, count(*) row_count
FROM
  fact.order_item_detail
UNION ALL
SELECT
  'draft_fact.order_item_detail' as table_name
, count(*) row_count
FROM
  draft_fact.order_item_detail
UNION ALL
SELECT
  'staging.order_item_detail' as table_name
, count(*) row_count
FROM
  staging.order_item_detail
UNION ALL
SELECT
  'fact.order_item' as table_name
, count(*) row_count
FROM
  fact.order_item
UNION ALL
SELECT
  'draft_fact.order_item' as table_name
, count(*) row_count
FROM
  draft_fact.order_item
UNION ALL
SELECT
  'fact.order_line' as table_name
, count(*) row_count
FROM
  fact.order_line
UNION ALL
SELECT
  'draft_fact.order_line' as table_name
, count(*) row_count
FROM
  draft_fact.order_line
UNION ALL
SELECT
  'fact.orders' as table_name
, count(*) row_count
FROM
  fact.orders
UNION ALL
SELECT
  'draft_fact.orders' as table_name
, count(*) row_count
FROM
  draft_fact.orders

/*
order_item_detail
check to see what's in fact that's missing from staging
result: 0 rows (this is good)
*/
SELECT
  old.*
FROM
  fact.order_item_detail old
left JOIN
  staging.order_item_detail new
  on old.order_item_detail_id = new.order_item_detail_id
WHERE
  new.order_item_detail_id is null

/*
check to see what's in staging that's missing from fact
result: 8523 rows -> they are all "estimates" aka quotes
*/
SELECT
new.record_type
  , count(*)
FROM
  staging.order_item_detail new
left JOIN
  fact.order_item_detail old
  on old.order_item_detail_id = new.order_item_detail_id
WHERE
  old.order_item_detail_id is null
group by 1


/*
order_item
check to see what's in fact that's missing from draft
result: 128 rows 
  mostly shipping other processing items.
  only 1 item of concern
select * from draft_fact.order_item where order_id_ns = '111-8775946-3401012'
select * from fact.order_item where order_id_edw = '111-8775946-3401012' 

nothing in fact that's missing from draft_fact
*/
SELECT
  old.*
FROM
  fact.order_item old
left JOIN
  draft_fact.order_item new
  on old.order_item_id = concat(new.order_id_ns,'_',new.item_id_ns)
WHERE
concat(new.order_id_ns,'_',new.item_id_ns) is null 
-- concat(new.order_id_ns,'_',new.item_id_ns) is null
/*
check quantities in order_item
                         booked  sold   fulfilled
fact.order_item      	9598826	9399682	8946135
draft_fact.order_item	9615246	9415104	8962555
diff                    16420   15422    16420

*/
select
'fact.order_item' as table_name
,SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping','Storage Fee') THEN quantity_booked
          ELSE 0
        END
      ) AS quantity_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping','Storage Fee') THEN quantity_sold
          ELSE 0
        END
      ) AS quantity_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping','Storage Fee') THEN quantity_fulfilled
          ELSE 0
        END) AS quantity_fulfilled
from
  fact.order_item
UNION ALL
  select
'draft_fact.order_item' as table_name
,SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping','Storage Fee') THEN quantity_booked
          ELSE 0
        END
      ) AS quantity_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping','Storage Fee') THEN quantity_sold
          ELSE 0
        END
      ) AS quantity_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping','Storage Fee') THEN quantity_fulfilled
          ELSE 0
        END) AS quantity_fulfilled
from
  draft_fact.order_item

/*
compare order volumes. Some cases where the old order volume was 2x reality. the new version resolves this ex SG-48654 and bosleys. quantity sold was 24 should be 12.
 -quantity_sold -> 32 orders where sold amout was 2x reality. fixed in new version
- quantity_booked -> 0 rows
- quantity_fulfilled -> 0 rows
*/

  
with old as
  (SELECT
  a.order_id_edw
  , a.plain_name
  , a.product_id_edw
  , a.order_item_id
  -- , new.order_id_edw  as order_id_edw_new
  , SUM(CASE WHEN a.plain_name NOT IN ('Tax', 'Shipping') THEN a.quantity_sold ELSE 0 END) quantity_sold
  , SUM(CASE WHEN a.plain_name NOT IN ('Tax', 'Shipping') THEN a.quantity_booked ELSE 0 END) quantity_booked
  , SUM(CASE WHEN a.plain_name NOT IN ('Tax', 'Shipping') THEN a.quantity_fulfilled ELSE 0 END) quantity_fulfilled
  FROM
    fact.order_item a
  GROUP BY
    a.order_id_edw
  , a.plain_name
  , a.product_id_edw
  , a.order_item_id
  )
, new as
  (SELECT
    a.order_id_ns as order_id_edw
  , concat(a.order_id_ns,'_',a.item_id_ns) as order_item_id
  , a.plain_name
  , a.product_id_edw
  -- , new.order_id_edw  as order_id_edw_new
  , SUM(CASE WHEN a.plain_name NOT IN ('Tax', 'Shipping') THEN a.quantity_sold ELSE 0 END) quantity_sold
  , SUM(CASE WHEN a.plain_name NOT IN ('Tax', 'Shipping') THEN a.quantity_booked ELSE 0 END) quantity_booked
  , SUM(CASE WHEN a.plain_name NOT IN ('Tax', 'Shipping') THEN a.quantity_fulfilled ELSE 0 END) quantity_fulfilled
  FROM
    draft_fact.order_item a
    GROUP BY
    a.order_id_ns
  , concat(a.order_id_ns,'_',a.item_id_ns) 
  , a.plain_name
  , a.product_id_edw)
SELECT
  old.order_id_edw as order_id_edw_old
, old.plain_name
, old.product_id_edw
, old.order_item_id
-- , new.order_id_edw  as order_id_edw_new
, old.quantity_sold as quantity_sold_old
, new.quantity_sold quantity_sold_new
, old.quantity_booked as quantity_booked_old
, new.quantity_booked as quantity_booked_new
, old.quantity_fulfilled as quantity_fulfilled_old
, new.quantity_fulfilled as quantity_fulfilled_new
FROM
  fact.order_item old
inner join
  draft_fact.order_item new
  on old.order_item_id = new.order_item_id
where
quantity_fulfilled_old != quantity_fulfilled_new
and old.plain_name not in ('Shipping','Tax')

  
select 
*
FROM
fact.order_item 
where order_id_edw = 'SG-48654'
and product_id_edw in (150)

select 
*
FROM
draft_fact.order_item 
where order_id_ns = 'SG-48654'
and product_id_edw in (150)

select 
  o.order_id_edw
, n.order_id_ns
-- , o.plain_name
, sum(o.quantity_booked) old
, sum(n.quantity_booked) new
FROM
fact.order_item o
left join
  draft_fact.order_item n
on o.order_id_edw = n.order_id_ns
  where true and o.order_id_edw = 'G2828694'
  and o.plain_name not in ('Tax','Shipping')
  and n.plain_name not in ('Tax','Shipping')
-- where n.order_id_ns is null
group by 1,2
having old!=new
  
select 
'fact'
, order_id_edw
, order_item_id
, product_id_edw
, sku
, plain_name
, quantity_booked
, quantity_sold
, quantity_fulfilled
FROM
fact.order_item 
where true and order_id_edw = 'GG-1339'
and plain_name not in ('Tax','Shipping')
-- and product_id_edw in (150)
union all
select 
'draft_fact'
, order_id_edw
, order_item_id
, product_id_edw
, sku
, plain_name
, quantity_booked
, quantity_sold
, quantity_fulfilled
FROM
draft_fact.order_item 
where order_id_ns = 'GG-1339'
-- and product_id_edw in (150)


with a as(
select 
'fact' table_name
, order_id_edw as order_id
, sum(quantity_booked)
, sum(quantity_sold) quantity_sold
, sum(quantity_fulfilled)
, sum(coalesce(quantity_booked,0)+coalesce(quantity_sold,0)+coalesce(quantity_fulfilled,0)) total
FROM
fact.order_item 
where true --order_id_edw = 'G2828694'
and plain_name not in ('Tax','Shipping')
group by 1,2
union all
select 
'draft_fact' table_name
, order_id_ns as order_id
, sum(quantity_booked)
, sum(quantity_sold) quantity_sold
, sum(quantity_fulfilled)
, sum(coalesce(quantity_booked,0)+coalesce(quantity_sold,0)+coalesce(quantity_fulfilled,0)) total
FROM
draft_fact.order_item 
where true --order_id_edw = 'G2828694'
and plain_name not in ('Tax','Shipping')
group by 1,2
)
SELECT
  a.table_name
, b.table_name as b_t
, a.total
, b.total as b_total
, a.order_id
FROM
  a
left join
 a b
on a.order_id = b.order_id
and a.table_name = 'fact' and b.table_name = 'draft_fact'
where a.quantity_sold != b.quantity_sold