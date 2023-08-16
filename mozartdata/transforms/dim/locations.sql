SELECT
  id,
  CASE
  when id = 1 then 'HQ DC - goodr.com' 
  when id = 3 then 'Cabana'
  end as actual_name
  
FROM
  netsuite.location