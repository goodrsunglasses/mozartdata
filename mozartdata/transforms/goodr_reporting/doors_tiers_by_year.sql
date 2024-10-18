SELECT
  tier,
  sum(case when doors is null then 1 else doors end) door_sum
FROM
  fact.customer_ns_map
  where tier is not null and category in ('Specialty','Key Account')
GROUP BY
  tier