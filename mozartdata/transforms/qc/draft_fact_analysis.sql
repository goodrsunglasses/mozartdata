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