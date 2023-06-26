SELECT
  ns.customer.id AS ns_cust_id,
  ns.customer.entityid AS ns_cust_id,
  ns.customer.altname AS ns_altname,
  ns.customer.defaultbillingaddress AS ns_defaultbillingaddressid, --- billing address id
  --- member since - do not know what this refers to ... this was just Josha's example, let's delete it from the required field list
  ns.customer.category AS ns_cust_category,
  ns.customer.isperson AS ns_cust_type,
  ns.customer.entitystatus AS ns_entitystatus,
  ns.customer.lastmodifieddate AS ns_cust_last_modified_date,
  ns.customer.email AS ns_cust_email,
  --- ns customer lead status - what does this mean? .... there is a field in NS front end that was labeled "lead status" (closed, etc)
  sh.customer.id as sh_cust_id, --- joined on email
  sh.customer.email as sh_cust_email
FROM
  netsuite.customer ns
FULL JOIN shopify.customer sh on sh.customer.email = ns.customer.email
--- test test
