SELECT
  *
FROM
  fact.orders o
WHERE
  channel = 'Marketing'
and location = 'HQ DC'


select distinct department, id from netsuite.item where itemtype ='Discount' and itemid = 'Discount - PR'
select * from netsuite.department where id=19
select * from fact.order_item_detail where item_id_ns = 7322