WITH sampled_data AS (
    SELECT *, 
           ROW_NUMBER() OVER(ORDER BY RANDOM()) AS row_num, 
           COUNT(*) OVER() AS total_row_count
      FROM draft_fact.customer
     SAMPLE (20)
)

SELECT *
  FROM sampled_data
 WHERE CASE WHEN total_row_count > 10 THEN row_num <= 10 ELSE TRUE END;