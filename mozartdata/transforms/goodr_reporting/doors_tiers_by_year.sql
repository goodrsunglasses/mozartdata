WITH
  cust_info AS (
    SELECT
      customer_id_edw,
      customer_id_ns,
      customer_name,
      customer_number,
      parent_id_ns,
      parent_customer_number,
      parent_name,
      category,
      tier,
      tier_ns,
      doors,
      CASE
        WHEN tier_ns != 'Named'
        AND doors IS NULL
        AND tier IS NOT NULL and parent_name is null THEN 1 --This is for when a customer record has a tier, but no doors, we add 1 door by default
        WHEN tier = 'Fleet Feet'
        AND parent_name IS NOT NULL
        AND doors IS NULL THEN 1--this is so that fleet feet children that are not parents can still count towards the doors
        ELSE doors
      END AS fixed_doors
    FROM
      fact.customer_ns_map
    WHERE
      category IN ('Specialty', 'Key Accounts') --Tiers and doors only matter for specialty
  )
SELECT
  *
FROM
  cust_info
WHERE
  tier = 'Fleet Feet'