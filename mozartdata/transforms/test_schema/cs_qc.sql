SELECT DISTINCT
  tran.custbody_goodr_shopify_order order_num,
  SUM(
    CASE
      WHEN tran.recordtype = 'salesorder' THEN 1
      ELSE 0
    END
  ) OVER (
    PARTITION BY
      order_num
  ) AS so_count,
  SUM(
    CASE
      WHEN tran.recordtype = 'itemfulfillment' THEN 1
      ELSE 0
    END
  ) OVER (
    PARTITION BY
      order_num
  ) AS if_count,
  SUM(
    CASE
      WHEN tran.recordtype = 'cashsale' THEN 1
      ELSE 0
    END
  ) OVER (
    PARTITION BY
      order_num
  ) AS cs_count,
  SUM(
    CASE
      WHEN tran.recordtype = 'invoice' THEN 1
      ELSE 0
    END
  ) OVER (
    PARTITION BY
      order_num
  ) AS if_count,
  SUM(
    CASE
      WHEN tran.recordtype = 'cashrefund' THEN 1
      ELSE 0
    END
  ) OVER (
    PARTITION BY
      order_num
  ) AS if_count
FROM
  netsuite.transaction tran
WHERE
  cseg7 = 10
  AND order_num = 'CS-LST-SD-G2496087'