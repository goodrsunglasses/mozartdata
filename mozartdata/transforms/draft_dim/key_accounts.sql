SELECT
  customer.id,
  customer.entityid,
  companyname,
  customer.email,
  salesrep AS salesrep_id,
  -- contact.entitytitle,
  -- contact.email,
  label,
  Addressee,
  addrText,
  addr1,
  addr2,
  addr3,
  state,
  city,
  zip
FROM
  netsuite.customer customer
  LEFT OUTER JOIN netsuite.customerAddressbook customerAddressbook ON customer.id = customerAddressbook.entity
  LEFT OUTER JOIN netsuite.customerAddressbookEntityAddress customerAddressbookEntityAddress ON customerAddressbook.addressbookaddress = customerAddressbookEntityAddress.nkey
  -- left outer join netsuite.contact contact on contact.company = customer.id
WHERE
  customer.id IN (
    12489,
    479,
    465,
    476,
    8147,
    73200,
    3363588,
    8169,
    3633497,
    3682848,
    467,
    466,
    2510,
    478,
    475,
    4484902,
    4533439
  )
  AND customer.entityid = 'CUST5'