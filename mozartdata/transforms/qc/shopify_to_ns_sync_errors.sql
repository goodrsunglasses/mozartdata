WITH
  combined AS (
    SELECT
      g.name,
      g.id,
      g.created_at,
      g.updated_at,
      g.email AS customer,
      g.customer_id,
      g.total_price,
      g.fulfillment_status,
      'goodr.com' AS channel,
      CASE
        WHEN t.order_id IS NOT NULL
        AND t.value = 'pl-exchange' THEN 'yes'
        ELSE 'no'
      END AS has_pl_exchange
    FROM
      shopify."ORDER" g
      LEFT JOIN shopify.order_tag t ON g.id = t.order_id
    WHERE
      cancelled_at IS NULL
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email AS customer,
      customer_id,
      total_price,
      fulfillment_status,
      'goodr can' AS channel,
      CASE
        WHEN t.order_id IS NOT NULL
        AND t.value = 'pl-exchange' THEN 'yes'
        ELSE 'no'
      END AS has_pl_exchange
    FROM
      goodr_canada_shopify."ORDER" gc
      LEFT JOIN goodr_canada_shopify.order_tag t ON gc.id = t.order_id
    WHERE
      cancelled_at IS NULL
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email AS customer,
      customer_id,
      total_price,
      fulfillment_status,
      'goodrwill' AS channel,
      CASE
        WHEN t.order_id IS NOT NULL
        AND t.value = 'pl-exchange' THEN 'yes'
        ELSE 'no'
      END AS has_pl_exchange
    FROM
      goodrwill_shopify."ORDER" gw
      LEFT JOIN goodrwill_shopify.order_tag t ON gw.id = t.order_id
    WHERE
      cancelled_at IS NULL
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email AS customer,
      customer_id,
      total_price,
      fulfillment_status,
      'sellgoodr can' AS channel,
      NULL AS has_pl_exchange
      --        CASE 
      --          WHEN t.order_id IS NOT NULL AND t.value = 'pl-exchange' THEN 'yes' 
      --          ELSE 'no' 
      --          END AS has_pl_exchange
    FROM
      sellgoodr_canada_shopify."ORDER" sc
      --      LEFT JOIN 
      --        sellgoodr_canada_shopify.order_tag t ON   sc.id = t.order_id    
    WHERE
      cancelled_at IS NULL
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email AS customer,
      customer_id,
      total_price,
      fulfillment_status,
      'cabana' AS channel,
      CASE
        WHEN t.order_id IS NOT NULL
        AND t.value = 'pl-exchange' THEN 'yes'
        ELSE 'no'
      END AS has_pl_exchange
    FROM
      cabana."ORDER" c
      LEFT JOIN cabana.order_tag t ON c.id = t.order_id
    WHERE
      cancelled_at IS NULL
    UNION
    SELECT
      name,
      id,
      created_at,
      updated_at,
      email AS customer,
      customer_id,
      total_price,
      fulfillment_status,
      'sellgoodr' AS channel,
      CASE
        WHEN t.order_id IS NOT NULL
        AND t.value = 'pl-exchange' THEN 'yes'
        ELSE 'no'
      END AS has_pl_exchange
    FROM
      specialty_shopify."ORDER" s
      LEFT JOIN specialty_shopify.order_tag t ON s.id = t.order_id
    WHERE
      cancelled_at IS NULL
  )
SELECT
  *,
  CASE
    WHEN customer IS NULL
    OR TRIM(customer) = '' THEN 'CS needs to update customer information'
    WHEN has_pl_exchange = 'yes'
    AND total_price > 0 THEN 'CS needs to add discount to zero out the order'
    ELSE 'Alex needs to resync'
  END AS to_do
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
  AND customer NOT IN ('integrations@goodr.com', 'kaden@goodr.com','jared@goodr.com')--Added here to account for test orders
ORDER BY
  created_at desc