SELECT
  netsuite.customer.id AS ns_customer_id,
  netsuite.customer.entityid AS ns_cusotmer_id,
  netsuite.customer.altname AS ns_altname,
  netsuite.customer.defaultbillingaddress AS ns_defaultbillingaddressid, --- shipping address id
  --- member since - do not know what this refers to ... this was just Josha's example, let's delete it from the required field list
  netsuite.customer.category AS ns_category,
  netsuite.customer.isperson AS ns_cust_type,
  netsuite.customer.entitystatus AS ns_entitystatus,
  netsuite.customer.lastmodifieddate AS ns_cust_last_modified_date,
  netsuite.customer.email AS ns_cust_email
  --- ns customer lead status - what does this mean? .... there is a field in NS front end that was labeled "lead status" (closed, etc)
FROM
  netsuite.customer