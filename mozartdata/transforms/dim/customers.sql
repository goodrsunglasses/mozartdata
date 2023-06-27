SELECT
  ns_cust.id AS ns_cust_id,
  ns_cust.entityid AS ns_cust_id,
  ns_cust.altname AS ns_altname,
  ns_cust.defaultbillingaddress AS ns_defaultbillingaddressid, --- billing address id
  --- member since - do not know what this refers to ... this was just Josha's example, let's delete it from the required field list
  ns_cust.category AS ns_cust_category,
  ns_cust.isperson AS ns_cust_type,
  ns_cust.entitystatus AS ns_entitystatus,
  ns_cust.lastmodifieddate AS ns_cust_last_modified_date,
  ns_cust.email AS ns_cust_email,
  --- ns customer lead status - what does this mean? .... there is a field in NS front end that was labeled "lead status" (closed, etc)
  shop_cust.id as sh_cust_id, --- joined on email
  shop_cust.email as sh_cust_email
FROM
  netsuite.customer ns_cust
FULL JOIN shopify.customer shop_cust on shop_cust.email = ns_cust.email
--- test test