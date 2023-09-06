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
        PARTITION BY
          order_num
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'salesorder' THEN 2
            ELSE 4
          END
      ) AS prioritized_timestamp_tran,
        FIRST_VALUE(tran.estgrossprofit) OVER (
        PARTITION BY
          order_num
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'invoice' THEN 2
            WHEN tran.recordtype = 'salesorder' THEN 3
            ELSE 4
          END
      )  AS gross_profit,
     FIRST_VALUE(tran.estgrossprofitpercent) OVER (
        PARTITION BY
          order_num
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'invoice' THEN 2
            WHEN tran.recordtype = 'salesorder' THEN 3
            ELSE 4
          END
      )  AS profit_percent,
      FIRST_VALUE(tran.totalcostestimate) OVER (
        PARTITION BY
          order_num
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'invoice' THEN 2
            WHEN tran.recordtype = 'salesorder' THEN 3
            ELSE 4
          END
      )  AS totalcostestimate,
      FIRST_VALUE(tran.entity) OVER (
        PARTITION BY
          order_num
        ORDER BY
          CASE
            WHEN tran.recordtype = 'cashsale' THEN 1
            WHEN tran.recordtype = 'invoice' THEN 2
            WHEN tran.recordtype = 'salesorder' THEN 3
            ELSE 4
          END
      )  AS customer_id
    FROM
      netsuite.transaction tran
      -- LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
      --       tran.status = transtatus.id
      --       AND tran.type = transtatus.trantype
      --     ) commented out until we know what we wanna do transaction status wise
    WHERE
      tran.recordtype IN ('cashsale', 'invoice', 'salesorder')
  and order_num = 'PRIORITY-RS-G1137675'