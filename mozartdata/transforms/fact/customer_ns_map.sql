WITH
  customer_category AS (
    SELECT DISTINCT
      cust.id,
      cust.entityid,
      cust.email,
      cust.isperson,
      channel.name AS channel,
      CASE
        WHEN channel IN (
          'Specialty',
          'Key Account',
          'Global',
          'Key Account CAN',
          'Specialty CAN'
        ) THEN 'B2B'
        WHEN channel IN (
          'Goodr.com',
          'Amazon',
          'Cabana',
          'Goodr.com CAN',
          'Prescription'
        ) THEN 'D2C'
        WHEN channel IN (
          'Goodrwill.com',
          'Customer Service CAN',
          'Marketing',
          'Customer Service'
        ) THEN 'INDIRECT'
      END AS b2b_d2c
    FROM
      netsuite.transaction tran
      LEFT OUTER JOIN netsuite.customer cust ON cust.id = tran.entity
      LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
  )
SELECT
  customer_id_edw,
  id as ns_customer_internal_id,
  entityid as ns_customer_id,  
  isperson as is_person_flag,
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
  END AS is_key_account_current_flag
FROM
  customer_category
  LEFT OUTER JOIN draft_dim.customers customers ON (
    customers.email = customer_category.email
    AND customer_category.b2b_d2c = customers.customer_category
  )