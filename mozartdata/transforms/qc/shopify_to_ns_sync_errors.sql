WITH
  combined AS (
    SELECT
      name,
      created_at,
      updated_at,
      fulfillment_status,
      'goodr.com' AS channel
    FROM
      shopify."ORDER" g
    UNION
    SELECT
      name,
      created_at,
      updated_at,
      fulfillment_status,
      'goodr can' AS channel
    FROM
      goodr_canada_shopify."ORDER"
    UNION
    SELECT
      name,
      created_at,
      updated_at,
      fulfillment_status,
      'goodrwill' AS channel
    FROM
      goodrwill_shopify."ORDER"
    UNION
    SELECT
      name,
      created_at,
      updated_at,
      fulfillment_status,
      'sellgoodr can' AS channel
    FROM
      sellgoodr_canada_shopify."ORDER"
    UNION
    SELECT
      name,
      created_at,
      updated_at,
      fulfillment_status,
      'cabana' AS channel
    FROM
      cabana."ORDER"
    UNION
    SELECT
      name,
      created_at,
      updated_at,
      fulfillment_status,
      'sellgoodr' AS channel
    FROM
      specialty_shopify."ORDER"
  )
SELECT
  *
FROM
  combined
WHERE
  name NOT IN (
    SELECT DISTINCT
      custbody_boomi_externalid
    FROM
      netsuite.transaction ns
    WHERE
      custbody_boomi_externalid IS NOT NULL
  )
  AND created_at > '2024-01-01'
  AND (
    fulfillment_status IS NULL
    OR fulfillment_status IN ('restocked', 'partial')
  )