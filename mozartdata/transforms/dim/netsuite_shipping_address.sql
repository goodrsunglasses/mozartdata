with base as (
  select
    a.nkey
  , 'invoice' as record_type
  , a.addr1
  , a.addr2
  , a.addr3
  , a.addressee
  , a.addrphone
  , a.addrtext
  , a.attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate
  from
    netsuite.invoiceshippingaddress a
  where
    _fivetran_deleted = false
  union all
  select
    a.nkey
  , 'cashsale' as record_type
  , a.addr1
  , a.addr2
  , a.addr3
  , a.addressee
  , a.addrphone
  , a.addrtext
  , a.attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate
  from
    netsuite.cashsaleshippingaddress a
  where
    _fivetran_deleted = false
  union all
  select
    a.nkey
  , 'cashrefund' as record_type
  , a.addr1
  , a.addr2
  , a.addr3
  , a.addressee
  , a.addrphone
  , a.addrtext
  , a.attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate
  from
    netsuite.cashrefundshippingaddress a
  where
    _fivetran_deleted = false
  union all
  select
    a.nkey
  , 'salesorder' as record_type
  , a.addr1
  , a.addr2
  , a.addr3
  , a.addressee
  , a.addrphone
  , a.addrtext
  , a.attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate
  from
    netsuite.salesordershippingaddress a
  where
    _fivetran_deleted = false
  union all
  select
    a.nkey
  , 'itemfulfillment' as record_type
  , a.addr1
  , a.addr2
  , a.addr3
  , a.addressee
  , a.addrphone
  , a.addrtext
  , a.attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate
  from
    netsuite.itemfulfillmentshippingaddress a
  where
    _fivetran_deleted = false
  union all
  select
    a.nkey
  , 'purchaseorder' as record_type
  , a.addr1
  , a.addr2
  , a.addr3
  , a.addressee
  , a.addrphone
  , a.addrtext
  , a.attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate
  from
    netsuite.purchaseordershippingaddress a
  where
    _fivetran_deleted = false
)

select
    concat(b.record_type,'_',b.nkey) as shipping_address_id_edw
  , b.nkey as shipping_address_id_ns
  , b.addr1 as address_1
  , b.addr2 as address_2
  , b.addr3 as address_3
  , b.addressee as customer_name
  , b.addrphone as phone_number
  , NULLIF(REGEXP_REPLACE(b.addrphone, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') as normalized_phone_number
  , b.addrtext as address_text
  , b.attention
  , b.city
  , coalesce(sa.fullname, b.state) as state
  , coalesce(sf.shortname, b.state) as state_abbreviation
  , b.country
  , b.zip as zip_code
  , case when b.country = 'US' then left(trim(b.zip),5) else b.zip end as normalized_zip_code
  , case when b.override = 'T' then true else false end as override_flag
  , b.dropdownstate as state_drop_down
from
  base b
left join
  netsuite.state sf
  on b.state = sf.fullname
  and b.country = sf.country
left join
  netsuite.state sa
  on b.state = sa.shortname
  and b.country = sa.country