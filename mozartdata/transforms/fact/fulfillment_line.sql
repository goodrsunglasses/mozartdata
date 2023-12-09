SELECT DISTINCT
  fulfillment_id_edw,
  order_id_edw,
  carrier,
  carrier_service,
  shipdate,
  shipment_cost,
  voided,
  country,
  state,
  city,
  shipment_id
FROM
  fact.fulfillment_item_detail