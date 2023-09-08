SELECT DISTINCT
  tran.custbody_goodr_shopify_order order_num,
  --Grabs the first value from the transaction type ranking, with a secondary sort that is going for oldest createddate first 
  FIRST_VALUE(tran.cseg7) OVER (
    PARTITION BY
      order_num
    ORDER BY
      CASE
        WHEN tran.recordtype = 'cashsale' THEN 1
        WHEN tran.recordtype = 'invoice' THEN 2
        WHEN tran.recordtype = 'salesorder' THEN 3
        ELSE 4
      END,
      tran.createddate ASC
  ) AS prioritized_channel_id,
  FIRST_VALUE(tran.entity) OVER (
    PARTITION BY
      order_num
    ORDER BY
      CASE
        WHEN tran.recordtype = 'cashsale' THEN 1
        WHEN tran.recordtype = 'invoice' THEN 2
        WHEN tran.recordtype = 'salesorder' THEN 3
        ELSE 4
      END,
      tran.createddate ASC
  ) AS prioritized_cust_id,
  --Grabs the first value from the transaction type ranking, this time ignoring invoices, with a secondary sort that is going for oldest createddate first 
  FIRST_VALUE(tran.createddate) OVER (
    ORDER BY
      CASE
        WHEN tran.recordtype = 'cashsale' THEN 1
        WHEN tran.recordtype = 'salesorder' THEN 2
        ELSE 3
      END,
      tran.createddate ASC
  ) AS oldest_createddate,
  -- Uses Coalesce logic to give us the Sum of all the cashsale record's estgrossprift, provided there are none then we take the invoices sum of estgrossprofit
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
  ) AS prioritized_grossprofit_sum,
   COALESCE(
    avg(
      CASE
        WHEN tran.recordtype = 'cashsale' THEN tran.estgrossprofitpercent
      END
    ) OVER (),
    avg(
      CASE
        WHEN tran.recordtype = 'invoice' THEN tran.estgrossprofitpercent
      END
    ) OVER ()
  ) AS prioritized_estgrossprofitpercent_avg,
   COALESCE(
    SUM(
      CASE
        WHEN tran.recordtype = 'cashsale' THEN tran.totalcostestimate
      END
    ) OVER (),
    SUM(
      CASE
        WHEN tran.recordtype = 'invoice' THEN tran.totalcostestimate
      END
    ) OVER ()
  ) AS prioritized_totalcostestimate_sum
FROM
  netsuite.transaction tran
  -- LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
  --       tran.status = transtatus.id
  --       AND tran.type = transtatus.trantype
  --     ) commented out until we know what we wanna do transaction status wise
WHERE
  tran.recordtype IN ('cashsale', 'invoice', 'salesorder')
  AND order_num = 'SG-72004'