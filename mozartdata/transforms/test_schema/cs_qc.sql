SELECT DISTINCT
  tran.custbody_goodr_shopify_order order_num,
  COUNT(
    DISTINCT CASE
      WHEN tran.recordtype = 'salesorder' THEN tran.id
    END
  ) AS so_count,
  COUNT(
    DISTINCT CASE
      WHEN tran.recordtype = 'itemfulfillment' THEN tran.id
    END
  ) AS if_count,
  COUNT(
    DISTINCT CASE
      WHEN tran.recordtype = 'cashsale' THEN tran.id
    END
  ) AS cs_count,
  COUNT(
    DISTINCT CASE
      WHEN tran.recordtype = 'invoice' THEN tran.id
    END
  ) AS inv_count,
  COUNT(
    DISTINCT CASE
      WHEN tran.recordtype = 'cashrefund' THEN tran.id
    END
  ) AS if_count
FROM
  netsuite.transaction tran
WHERE
  cseg7 = 10
  AND order_num = 'CS-LST-SD-G2496087'
GROUP BY
  order_num