SELECT
  ord.amazon_order_id,
  ord.purchase_date,
  event.posted_date,
  event.event_type,
  item.seller_sku,
  item.item_kind,
  item._fivetran_id item_id,
  charge.charge_type ctype,
  fee.fee_type ftype,
  charge.currency_code ccode,
  fee.currency_code fcode,
  charge.currency_amount cmount,
  fee.currency_amount fmount
FROM
  amazon_selling_partner.orders ord
  LEFT OUTER JOIN amazon_selling_partner.FINANCIAL_SHIPMENT_EVENT event ON event.amazon_order_id = ord.amazon_order_id
  LEFT OUTER JOIN amazon_selling_partner.FINANCIAL_SHIPMENT_EVENT_ITEM item ON item.financial_shipment_event_id = event._fivetran_id
  LEFT OUTER JOIN amazon_selling_partner.FINANCIAL_CHARGE_COMPONENT charge ON charge.linked_to_id = item._fivetran_id
  LEFT OUTER JOIN amazon_selling_partner.financial_fee_component fee ON fee.linked_to_id = item._fivetran_id
WHERE
  item_id = 'STMWGoWF2lPRHJ80b6cBTyQ5qNE='
order by ctype
  -- WHERE
  --   amazon_order_id = '113-1653928-2853051'
  -- SELECT
  --   event.amazon_order_id,
  -- FROM
  --   amazon_selling_partner.FINANCIAL_SHIPMENT_EVENT event
  --   LEFT OUTER JOIN
  -- WHERE
  --   amazon_order_id = '113-1653928-2853051'
  -- SELECT
  --   *
  -- FROM
  --   amazon_selling_partner.FINANCIAL_SHIPMENT_EVENT_ITEM
  -- WHERE
  --   financial_shipment_event_id = '24FlT4td8Bg2JGt4AZprc5tUAw4='
  -- SELECT
  --   *
  -- FROM
  --   amazon_selling_partner.FINANCIAL_CHARGE_COMPONENT
  -- WHERE
  --   linked_to_id = 'XT+TC7upWm2MiifW6ez+8cHVWWE='
  -- SELECT
  --   *
  -- FROM
  --   amazon_selling_partner.financial_fee_component
  -- WHERE
  --   linked_to_id = 'XT+TC7upWm2MiifW6ez+8cHVWWE='