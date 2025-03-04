with base as (
  select
    a.nkey as address_id_ns
  , 'invoice' as record_type
  , a.addr1 as address_1
  , a.addr2 as address_2
  , a.addr3 as address_3
  , a.addressee as customer_name
  , a.addrphone as phone_number
  , a.addrtext as address_text
  , a.attention as attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate as state_drop_down
  from
    netsuite.invoiceshippingaddress a
  where
    _fivetran_deleted = false
  union all
  select
    a.nkey as address_id_ns
  , 'cashsale' as record_type
  , a.addr1 as address_1
  , a.addr2 as address_2
  , a.addr3 as address_3
  , a.addressee as customer_name
  , a.addrphone as phone_number
  , a.addrtext as address_text
  , a.attention as attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate as state_drop_down
  from
    netsuite.cashsaleshippingaddress a
  where
    _fivetran_deleted = false
  union all
  select
    a.nkey as address_id_ns
  , 'cashrefund' as record_type
  , a.addr1 as address_1
  , a.addr2 as address_2
  , a.addr3 as address_3
  , a.addressee as customer_name
  , a.addrphone as phone_number
  , a.addrtext as address_text
  , a.attention as attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate as state_drop_down
  from
    netsuite.cashrefundshippingaddress a
  where
    _fivetran_deleted = false
  union all
  select
    a.nkey as address_id_ns
  , 'invoice' as record_type
  , a.addr1 as address_1
  , a.addr2 as address_2
  , a.addr3 as address_3
  , a.addressee as customer_name
  , a.addrphone as phone_number
  , a.addrtext as address_text
  , a.attention as attention
  , a.city
  , a.state
  , a.country
  , a.zip
  , a.override
  , a.dropdownstate as state_drop_down
  from
    netsuite.invoiceshippingaddress a
  where
    _fivetran_deleted = false
)
select
  coalesce(b.record_type,'_',b.address_id_ns) as order_address_id_edw
  , b.address_id_ns as order_address_id_ns
  , b.record_type
  , b.address_1
  , b.address_2
  , b.address_3
  , b.customer_name
  , b.phone_number
  , NULLIF(REGEXP_REPLACE(b.phone_number, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') as normalized_phone_number
  , b.address_text
  , b.attention
  , b.city
  , b.state
  , s.shortname as state_abbreviation
  , b.country
  , b.zip
  , case when b.override = 'T' then true else false end as override_flag
  , b.state_drop_down
from
  base b
left join
  netsuite.state s
  on b.state = s.state
  and b.country = s.country