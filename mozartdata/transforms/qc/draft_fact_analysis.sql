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
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_booked
          ELSE 0
        END
      ) AS quantity_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_sold
          ELSE 0
        END
      ) AS quantity_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_fulfilled
          ELSE 0
        END) AS quantity_fulfilled
from
  fact.order_item
UNION ALL
  select
'draft_fact.order_item' as table_name
,SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_booked
          ELSE 0
        END
      ) AS quantity_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_sold
          ELSE 0
        END
      ) AS quantity_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_fulfilled
          ELSE 0
        END) AS quantity_fulfilled
from
  draft_fact.order_item

SELECT
  old.order_id_edw as order_id_edw_old
, old.plain_name
, old.product_id_edw
-- , new.order_id_edw  as order_id_edw_new
, SUM(CASE WHEN old.plain_name NOT IN ('Tax', 'Shipping') THEN old.quantity_sold ELSE 0 END) quantity_sold_old
, SUM(CASE WHEN new.plain_name NOT IN ('Tax', 'Shipping') THEN new.quantity_sold ELSE 0 END) quantity_sold_new
FROM
  fact.order_item old
inner join
  draft_fact.order_item new
  on old.order_item_id = concat(new.order_id_ns,'_',new.item_id_ns)
group by
 old.order_id_edw
, old.plain_name
, old.product_id_edw
-- , new.order_id_edw
having
quantity_sold_old != quantity_sold_new

select 
*
FROM
fact.order_item 
where order_id_edw = 'SG-MASTERS2301'
and product_id_edw in (150)

select 
*
FROM
draft_fact.order_item 
where order_id_ns = 'SG-MASTERS2301'
and product_id_edw in (150)