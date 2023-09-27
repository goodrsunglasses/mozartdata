SELECT
  channel.name AS channel,
  transaction_date,
  COUNT(order_num) orders_count,
  SUM(quantity_sold) units_sold
FROM
  (
    SELECT DISTINCT
      tran.custbody_goodr_shopify_order order_num,
      DATE_TRUNC('DAY', tran.createddate)::DATE AS transaction_date,
      SUM(
        CASE
          WHEN tranline_ns.itemtype = 'InvtPart' THEN -1 * quantity
          WHEN tranline_ns.itemtype = 'NonInvtPart'
          AND tranline_ns.custcol2 LIKE '%GC-%' THEN -1 * quantity
          ELSE 0
        END
      ) over (
        PARTITION BY
          order_num
      ) AS quantity_sold,
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
      ) AS prioritized_channel_id
    FROM
      netsuite.transaction tran
      LEFT OUTER JOIN netsuite.transactionline tranline_ns ON tranline_ns.transaction = tran.id
  where order_num is not null
  ) order_numbers
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON order_numbers.prioritized_channel_id = channel.id
WHERE
  DATE_TRUNC('DAY', transaction_date)::DATE >= CURRENT_DATE() - INTERVAL '15 DAY'
  AND DATE_TRUNC('DAY', transaction_date)::DATE < CURRENT_DATE()
GROUP BY
  transaction_date,
  channel
ORDER BY
  transaction_date desc