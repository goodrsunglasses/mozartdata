with sgs as (
  SELECT
  item_id_ns,
  display_name
FROM
  dim.product
WHERE
  merchandise_class = 'SNOW G' 
  and item_id_ns <>  3532
  )
SELECT
  t.item_id_ns,
  display_name,
  round(sum(net_amount),2)
FROM
  fact.gl_transaction t
  inner join sgs on sgs.item_id_ns = t.item_id_ns
where account_number = 4000
and posting_flag 
group by all