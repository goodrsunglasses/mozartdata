WITH
  customer_category AS (
    SELECT DISTINCT
      cust.id,
      cust.entityid,
      cust.email,
      cust.isperson,
      channel.name AS channel,
      ROW_NUMBER() over (
        PARTITION BY
          cust.email,
          channel.customer_category
        ORDER BY
          CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) desc
      ) AS rn,
        channel.customer_category as b2b_d2c
    FROM
      netsuite.transaction tran
      LEFT OUTER JOIN netsuite.customer cust ON cust.id = tran.entity
      LEFT OUTER JOIN dim.channel channel ON tran.cseg7 = channel.channel_id_ns
    WHERE
      tran.recordtype IN (
        'cashsale',
        'invoice',
        'salesorder',
        'itemfulfillment',
        'cashrefund'
      )
  )
SELECT
  customer_id_edw,
  id AS customer_internal_id_ns,
  entityid AS customer_id_ns,
  isperson AS is_person_flag,
  customer_category.email,
  CASE
    WHEN id IN (
      12489,
      479,
      465,
      476,
      8147,
      73200,
      3363588,
      8169,
      3633497,
      3682848,
      467,
      466,
      2510,
      478,
      475,
      4484902,
      4533439
    ) THEN TRUE
    ELSE FALSE
  END AS is_key_account_current_flag,
  b2b_d2c,
  CASE
    WHEN MIN(rn) = 1 THEN TRUE
    ELSE FALSE
  END AS ns_primary_id_flag
FROM
  customer_category
  LEFT OUTER JOIN dim.customer customers ON (
    LOWER(customers.email) = LOWER(customer_category.email)
    AND customer_category.b2b_d2c = customers.customer_category
  )
WHERE
  customer_internal_id_ns IS NOT NULL
GROUP BY
  customer_id_edw,
  id,
  entityid,
  isperson,
  CASE
    WHEN id IN (
      12489,
      479,
      465,
      476,
      8147,
      73200,
      3363588,
      8169,
      3633497,
      3682848,
      467,
      466,
      2510,
      478,
      475,
      4484902,
      4533439
    ) THEN TRUE
    ELSE FALSE
  END,
  b2b_d2c,
  customer_category.email
ORDER BY
  customer_id_edw