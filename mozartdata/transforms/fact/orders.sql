with priority as (
tran.custbody_goodr_shopify_order order_num,
      FIRST_VALUE(tran.id) OVER (
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
      ) AS id
  from fact.orderline