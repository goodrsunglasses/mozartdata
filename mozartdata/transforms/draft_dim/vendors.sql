SELECT
  id as vendor_id_edw,
  id as vendor_id_ns,
  altname as name,
  balance,
  companyname as company_name,
  currency as currency_id_ns,
  defaultbillingaddress as billing_address_id_ns,
  defaultshippingaddress as shipping_address_id_ns,
  email,
  globalsubscriptionstatus as global_subscription_status_id_ns
FROM
  netsuite.vendor