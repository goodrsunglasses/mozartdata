SELECT DISTINCT
  tran.custbody_goodr_shopify_order order_num,
  FIRST_VALUE(tran.cseg7) OVER (
    PARTITION BY
      order_num
    ORDER BY
      CASE
        WHEN tran.recordtype = 'cashsale' THEN 1
        WHEN tran.recordtype = 'invoice' THEN 2
        WHEN tran.recordtype = 'salesorder' THEN 3
        ELSE 4
      END
  ) AS prioritized_channel_id,
  FIRST_VALUE(tran.createddate) OVER (
    ORDER BY
      CASE
        WHEN tran.recordtype = 'cashsale' THEN 1
        WHEN tran.recordtype = 'salesorder' THEN 2
        ELSE 3
      END,
      tran.createddate ASC
  ) AS oldest_createddate,
  COALESCE(
    SUM(
      CASE
        WHEN tran.recordtype = 'cashsale' THEN tran.estgrossprofit
      END
    ) OVER (),
    SUM(
      CASE
        WHEN tran.recordtype = 'invoice' THEN tran.estgrossprofit
      END
    ) OVER ()
  ) AS prioritized_grossprofit_sum
FROM
  netsuite.transaction tran
  -- LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
  --       tran.status = transtatus.id
  --       AND tran.type = transtatus.trantype
  --     ) commented out until we know what we wanna do transaction status wise
WHERE
  tran.recordtype IN ('cashsale', 'invoice', 'salesorder')
  AND order_num = 'CS-WQT-LG-SG-71522'