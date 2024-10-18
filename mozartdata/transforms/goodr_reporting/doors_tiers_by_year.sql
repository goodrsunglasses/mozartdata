--The idea behind this query is to standardize this bs information so that its not a fire drill each time we want it, sadly a bunch of business logic needs to be applied to make doors and tiers behave
--Ideally this query will also link to order level information so that we can grab "Dates" for these customers to add the _year part but for right now thats a whole other thing.
--ASSUMPTIONS MADE WITHIN THIS QUERY: Since NS doors' field is manually updated, and not maintained strictly by any one team, its fair to "fix" it using business logic
WITH
  parent_doors AS ( --Parent doors isn't on the table lmao
    SELECT
      *
    FROM
      fact.customer_ns_map
    WHERE
      is_parent_flag
  ),
  cust_info AS (
    SELECT
      map.customer_id_edw,
      map.customer_id_ns,
      map.customer_name,
      map.customer_number,
      map.parent_id_ns,
      map.parent_customer_number,
      map.parent_name,
      parent_doors.doors parent_doors,
      map.category,
      CASE
        WHEN map.tier IS NULL
        AND map.company_name = 'Target' THEN 'Target' --Seems stupid that target has 400+ doors but no tier.
        ELSE map.tier
      END AS tier,
      map.tier_ns,
      map.doors,
      CASE
        WHEN map.tier_ns != 'Named'
        AND map.doors IS NULL
        AND map.tier IS NOT NULL
        AND map.parent_name IS NULL THEN 1 --This is for when a customer record has a tier, but no doors, we add 1 door by default
        WHEN map.tier = 'Fleet Feet'
        AND map.parent_name IS NOT NULL
        AND map.doors IS NULL THEN 1 --this is so that fleet feet children that are not parents can still count towards the doors
        ELSE map.doors
      END AS fixed_doors
    FROM
      fact.customer_ns_map map
      LEFT OUTER JOIN parent_doors ON parent_doors.customer_id_ns = map.parent_id_ns
    WHERE
      map.category IN ('Specialty', 'Key Account') --Tiers and doors only matter for specialty
  )
SELECT
  *
FROM
  cust_info