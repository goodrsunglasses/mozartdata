--The idea behind this query is to standardize this bs information so that its not a fire drill each time we want it, sadly a bunch of business logic needs to be applied to make doors and tiers behave
--Ideally this query will also link to order level information so that we can grab "Dates" for these customers to add the _year part but for right now thats a whole other thing.
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
        AND tier IS NOT NULL
        AND parent_name IS NULL THEN 1 --This is for when a customer record has a tier, but no doors, we add 1 door by default
        WHEN tier = 'Fleet Feet'
        AND parent_name IS NOT NULL
        AND doors IS NULL THEN 1 --this is so that fleet feet children that are not parents can still count towards the doors
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