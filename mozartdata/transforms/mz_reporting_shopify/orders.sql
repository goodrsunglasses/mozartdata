-- Step 1. Select specific columns from the Shopify source table named ORDER and include only the rows that have not been deleted by Fivetran.

WITH renamed AS (
  SELECT
    id AS order_id,
    CAST(processed_at as date) AS processed_timestamp,
    updated_at AS updated_timestamp,
    user_id AS user_id,
    total_discounts AS total_discounts,
    total_line_items_price AS total_line_items_price,
    total_price AS total_price,
    total_tax AS total_tax,
    source_name AS source_name,
    subtotal_price AS subtotal_price,
    taxes_included AS has_taxes_included,
    total_weight AS total_weight,
    landing_site_base_url AS landing_site_base_url,
    location_id AS location_id,
    name AS name,
    note AS note,
    number AS number,
    order_number AS order_number,
    cancel_reason AS cancel_reason,
    cancelled_at AS cancelled_timestamp,
    cart_token AS cart_token,
    checkout_token AS checkout_token,
    closed_at AS closed_timestamp,
    created_at AS created_timestamp,
    currency AS currency,
    customer_id AS customer_id,
    email AS email,
    financial_status AS financial_status,
    fulfillment_status AS fulfillment_status,
   --- processing_method AS processing_method,
    referring_site AS referring_site,
    billing_address_address_1 AS billing_address_address_1,
    billing_address_address_2 AS billing_address_address_2,
    billing_address_city AS billing_address_city,
    billing_address_company AS billing_address_company,
    billing_address_country AS billing_address_country,
    billing_address_country_code AS billing_address_country_code,
    billing_address_first_name AS billing_address_first_name,
    billing_address_last_name AS billing_address_last_name,
    billing_address_latitude AS billing_address_latitude,
    billing_address_longitude AS billing_address_longitude,
    billing_address_name AS billing_address_name,
    billing_address_phone AS billing_address_phone,
    billing_address_province AS billing_address_province,
    billing_address_province_code AS billing_address_province_code,
    billing_address_zip AS billing_address_zip,
    browser_ip AS browser_ip,
    buyer_accepts_marketing AS has_buyer_accepted_marketing,
    total_shipping_price_set AS total_shipping_price_set,
    shipping_address_address_1 AS shipping_address_address_1,
    shipping_address_address_2 AS shipping_address_address_2,
    shipping_address_city AS shipping_address_city,
    shipping_address_company AS shipping_address_company,
    shipping_address_country AS shipping_address_country,
    shipping_address_country_code AS shipping_address_country_code,
    shipping_address_first_name AS shipping_address_first_name,
    shipping_address_last_name AS shipping_address_last_name,
    shipping_address_latitude AS shipping_address_latitude,
    shipping_address_longitude AS shipping_address_longitude,
    shipping_address_name AS shipping_address_name,
    shipping_address_phone AS shipping_address_phone,
    shipping_address_province AS shipping_address_province,
    shipping_address_province_code AS shipping_address_province_code,
    shipping_address_zip AS shipping_address_zip,
    test AS is_test_order,
    token AS token,
    _fivetran_synced AS _fivetran_synced --The below script allows for pass through columns.
,
    CAST('' AS VARCHAR) AS source_relation
  FROM
    shopify."ORDER"
  where _fivetran_deleted = false -- remove fivetran deleted rows
),

-- Step 2. Calculate the shipping cost and the number of line items per order, and include the columns from the previous CTE renamed.

  joined AS (
    SELECT
      orders.*,
      COALESCE(
        CAST(
          parse_json(total_shipping_price_set) [ 'shop_money' ] [ 'amount' ] AS FLOAT
        ),
        0
      ) AS shipping_cost,
      (orders.total_price) AS order_adjusted_total,
      order_lines.line_item_count
    FROM
      renamed as orders
      LEFT JOIN mz_reporting_shopify.orders__order_line_aggregates as order_lines ON orders.order_id = order_lines.order_id
      AND orders.source_relation = order_lines.source_relation
  ),
  
--  Step 3. Add a sequence number for each customer order, partitioned by customer_id and source_relation.

  windows AS (
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY customer_id,
        source_relation
        ORDER BY
          created_timestamp
      ) AS customer_order_seq_number
    FROM
      joined
  ),

-- Step 4. Categorize each order as "new" or "repeat" based on the sequence number.

  new_vs_repeat AS (
    SELECT
      *,
      CASE
        WHEN customer_order_seq_number = 1 THEN 'new'
        ELSE 'repeat'
      END AS new_vs_repeat
    FROM
      windows
  )
  
-- Step 5. Select all columns from the CTE new_vs_repeat and calculate several additional columns based on the processed timestamp, including the number of weeks and months since the latest order, and the day of the week for each order.

  SELECT
    *,
    CEIL(((SELECT MAX(processed_timestamp) from renamed) - processed_timestamp + 1)/7) as num_weeks_ago,
    CEIL(((SELECT MAX(processed_timestamp) from renamed) - processed_timestamp + 1)/28) as num_months_ago,
    MOD(((SELECT MAX(processed_timestamp) from renamed) - processed_timestamp), 7) as num_day_in_week
  FROM
    new_vs_repeat