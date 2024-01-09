SELECT
  staging.*,
  exceptions.dupe_flag
FROM
  staging.order_item_detail staging
  LEFT OUTER JOIN exceptions.order_item_detail exceptions ON exceptions.transaction_id_ns = staging.transaction_id_ns
WHERE
  dupe_flag IS NULL
  OR dupe_flag = FALSE