SELECT
  previousdoc as transaction_id_ns
, pt.tranid as transaction_number_ns
, pt.recordtype as record_type
, date(pt.trandate) as transaction_date
, tl.nextdoc as next_transaction_id_ns
, nt.tranid as next_transaction_number_ns
, nt.recordtype as next_record_type
, date(nt.trandate) as next_transaction_date
, tl.linktype as link_type
, tl.amount
FROM
  netsuite.nexttransactionaccountinglinelink tl
LEFT JOIN
  netsuite.transaction pt
  ON pt.id = tl.previousdoc
LEFT JOIN
  netsuite.transaction nt
  ON nt.id = tl.nextdoc
WHERE
  (tl._fivetran_deleted = false or tl._fivetran_deleted is null)
