/*
This QC was performed on 2/24/2024 by Josha. So row counts/data profile is as of that day.
QC steps
1. update all of the draft_fact tables (staging.order_item_detail -> draft_fact.orders)
2. check row counts
3. profile the data
4. spot check
*/
/*
row count check
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