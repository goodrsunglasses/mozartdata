SELECT 
      DISTINCT      (department_id_ns),
      department,
      case 
          when department_id_ns in (25,18331,12,53241) then 'money'
          when department_id_ns in (24,4,53239,18333,53243) then 'retail'
          when department_id_ns in (16,20,22,6,21) then 'creative'
          when department_id_ns in (46536,18,2,19,1,53242,3,8) then 'consumer'
          when department_id_ns in (9,53138,23,11,18332,14,17) then 'ops'
          when department_id_ns in (26,53137,27,13,28,23334,29) then 'people'
          else 'unknown' end as herd
    FROM
      fact.gl_transaction gt
    WHERE
      posting_flag = 'true'
      AND to_date(posting_period, 'MON YYYY') >= '2022-01-01'
    GROUP BY
      ALL