with gl as 
  (SELECT * FROM fact.gl_transaction where account_number = 4000 and posting_flag = true 
  and channel in ('Goodr.com', 'goodr.ca','Specialty','Specialty CAN','Amazon','Amazon Canada','Key Accounts','Key Account CAN','Cabana','Global','Prescription'))

SELECT country, sUM(net_amount) as revenue
  
  FROM 
 (SELECT gl.*,
  coalesce(ifaddy.country,invaddy.country, csaddy.country,soaddy.country, 
  CASE 
    WHEN gl.channel = 'Goodr.com' then 'US'
    WHEN gl.channel = 'goodr.ca' then 'CA'
  WHEN gl.channel = 'Specialty' then 'US'
   WHEN gl.channel = 'Specialty CAN' then 'CA'
  when gl.channel = 'Cabana' then 'US'
  when gl.channel = 'Amazon' then 'US'
  when gl.channel = 'Amazon Canada' then 'CA'
    when gl.channel = 'Prescription' then 'US'
    when gl.channel = 'Key Accounts' then 'US'
    when gl.channel = 'Key Account CAN' then 'CA'
    WHEN entity LIKE 'The Trustee for the Reuss Family Trust T/as Injinji Performance Products Pty Ltd' THEN 'AU'
    WHEN entity = '2Pure Ltd' THEN 'UK'
    WHEN entity = 'BLUETAG.Inc' THEN 'JP'
    WHEN entity = 'Back River Group' THEN 'CA'
    WHEN entity = 'REV EDITION CO., LTD.' THEN 'TH'
    WHEN entity = 'SING PHIL SPORTS PTE. LTD.' THEN 'SG'
   when entity = 'Asesores Profesionales/ Caballero Zuniga' then 'MX'
  when entity = 'GUANACO RUN' then 'CR'
  when line_entity = 'Back River Group' then 'CA'
  when gl.order_id_ns = 'SO1915903' THEN 'DE'
  when gl.record_type = 'journalentry' then 'UNKNOWN'
  when gl.order_id_ns = 'CS-CAPITALIDEASMERCK112822' then 'US'
END ) as country
  --SUM(net_amount) revenue
  FROM gl 
  LEFT JOIN fact.order_item_detail oid on oid.transaction_id_ns = gl.transaction_id_ns and oid.item_id_ns = gl.item_id_ns
  LEFT JOIN netsuite.invoiceshippingaddress invaddy ON invaddy.nkey = oid.shippingaddress
  LEFT JOIN netsuite.cashsaleshippingaddress csaddy on oid.shippingaddress = csaddy.nkey
  LEFT JOIN netsuite.salesordershippingaddress soaddy on soaddy.nkey = oid.shippingaddress
  LEFT JOIN netsuite.itemfulfillmentshippingaddress ifaddy on ifaddy.nkey = oid.shippingaddress
   where  gl.record_type not like '%loyalty%' ) 
where country <> 'UK'

  group by all
ORDER BY 2 DESC


--this is product sales plus loyalty income