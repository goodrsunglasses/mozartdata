WITH
  customer_category AS (
    SELECT DISTINCT
      cust.id,
      cust.entityid,
      cust.email,
      cust.altname,
      cust.companyname,
      cust.isperson,
      channel.name AS channel,
      ROW_NUMBER() over (
        PARTITION BY
          cust.email,
          channel.customer_category
        ORDER BY
          CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) desc
      ) AS rn,
        channel.customer_category as b2b_d2c,
        cust.custentityam_primary_sport,
        cust.custentityam_secondary_sport,
        cust.custentityam_tertiary_sport,
        cust.custentityam_doors,
        cust.custentityam_buyer_name,
        cust.custentityam_buyer_email,
        cust.custentityam_pop,
        cust.custentityam_logistics,
        cust.custentityam_city_1,
        cust.custentityam_city_2,
        cust.custentityam_city_3,
        cust.custentityam_state_1,
        cust.custentityam_state_2,
        cust.custentityam_state_3
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
  altname AS customer_name,
  companyname AS company_name,
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
  END AS primary_id_flag,
  custentityam_primary_sport as primary_sport,
  custentityam_secondary_sport as secondary_sport,
  custentityam_tertiary_sport as tertiary_sport,
  custentityam_doors as doors,
  custentityam_buyer_name as buyer_name,
  custentityam_buyer_email as buyer_email,
  custentityam_pop as pop,
  custentityam_logistics as logistics,
  custentityam_city_1 as city_1,
  custentityam_city_2 as city_2,
  custentityam_city_3 as city_3,
  custentityam_state_1 as state_1,
  custentityam_state_2 as state_2,
  custentityam_state_3 as state_3
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
  altname,
  companyname,
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
  customer_category.email,
  custentityam_primary_sport,
  custentityam_secondary_sport,
  custentityam_tertiary_sport,
  custentityam_doors,
  custentityam_buyer_name,
  custentityam_buyer_email,
  custentityam_pop,
  custentityam_logistics,
  custentityam_city_1,
  custentityam_city_2,
  custentityam_city_3,
  custentityam_state_1,
  custentityam_state_2,
  custentityam_state_3
ORDER BY
  customer_id_edw