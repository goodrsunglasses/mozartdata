SELECT DISTINCT
  tran.custbody_goodr_shopify_order order_num SUM(tran.id) OVER (
    PARTITION BY
      order_num
    ORDER BY
      CASE
        WHEN tran.recordtype = 'salesorder' THEN 1
        ELSE 0
      END,
      tran.createddate ASC
  ) AS so_count,
FROM
  netsuite.transaction tran
WHERE
  cseg7 = 10