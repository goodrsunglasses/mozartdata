/*

*/
SELECT
  old.*
FROM
  fact.orders old
left JOIN
  draft_fact.orders new
  on old.order_id_edw = new.order_id_ns --
where
  new.order_id_ns is null