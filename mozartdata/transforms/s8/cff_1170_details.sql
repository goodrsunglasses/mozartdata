SELECT
      gt.transaction_id_ns
    , gt.record_type
    , null as transaction_reference--concat(gt.record_type,': ',gt.transaction_number_ns) as transaction_reference
    , gt.transaction_date
    , gt.posting_period
    , gt.account_number
    , ga.account_display_name as account_name
    , cnm.company_name
    , gt.channel
    , gt.memo
    , sum(gt.credit_amount) credit
    , sum(gt.debit_amount) debit
    , sum(gt.net_amount) net
   FROM
     fact.gl_transaction gt
   INNER JOIN
    dim.gl_account ga
    on gt.account_id_edw = ga.account_id_edw
   left join
    fact.customer_ns_map cnm
    on gt.customer_id_ns = cnm.customer_id_ns
   WHERE
       gt.account_number in (1170)
   AND gt.posting_flag
  GROUP BY ALL