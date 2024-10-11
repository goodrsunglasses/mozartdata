WITH
  combined AS (
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email as customer,
      customer_id,
      total_price,
      fulfillment_status,
      'goodr.com' AS channel
    FROM
      shopify."ORDER" g
    WHERE cancelled_at is null
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email as customer,
      customer_id,
      total_price,
      fulfillment_status,
      'goodr can' AS channel
    FROM
      goodr_canada_shopify."ORDER"
    WHERE cancelled_at is null
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email as customer,
      customer_id,
      total_price,
      fulfillment_status,
      'goodrwill' AS channel
    FROM
      goodrwill_shopify."ORDER"
    WHERE cancelled_at is null
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email as customer,
      customer_id,
      total_price,
      fulfillment_status,
      'sellgoodr can' AS channel
    FROM
      sellgoodr_canada_shopify."ORDER"
    WHERE cancelled_at is null
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email as customer,
      customer_id,
      total_price,
      fulfillment_status,
      'cabana' AS channel
    FROM
      cabana."ORDER"
    WHERE cancelled_at is null
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email as customer,
      customer_id,
      total_price,
      fulfillment_status,
      'sellgoodr' AS channel
    FROM
      specialty_shopify."ORDER"
    WHERE cancelled_at is null
  )
SELECT
  *,
  case WHEN customer IS NULL OR TRIM(customer) = '' then 'CS needs to update customer information' else 'Alex needs to resync' end as to_do
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
ORDER BY created_at desc