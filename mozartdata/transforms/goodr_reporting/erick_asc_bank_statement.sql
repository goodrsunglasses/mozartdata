SELECT
  ord.amazon_order_id,
  ord.purchase_date,
  event.posted_date,
  event.event_type,
FROM
  amazon_selling_partner.orders ord
  left outer join amazon_selling_partner.FINANCIAL_SHIPMENT_EVENT event on event.amazon_order_id = ord.amazon_order_id
WHERE
  amazon_order_id = '113-1653928-2853051'
SELECT
  event.amazon_order_id,
FROM
  amazon_selling_partner.FINANCIAL_SHIPMENT_EVENT event
  LEFT OUTER JOIN
WHERE
  amazon_order_id = '113-1653928-2853051'
SELECT
  *
FROM
  amazon_selling_partner.FINANCIAL_SHIPMENT_EVENT_ITEM
WHERE
  financial_shipment_event_id = '24FlT4td8Bg2JGt4AZprc5tUAw4='
SELECT
  *
FROM
  amazon_selling_partner.FINANCIAL_CHARGE_COMPONENT
WHERE
  linked_to_id = 'XT+TC7upWm2MiifW6ez+8cHVWWE='
SELECT
  *
FROM
  amazon_selling_partner.financial_fee_component
WHERE
  linked_to_id = 'XT+TC7upWm2MiifW6ez+8cHVWWE='