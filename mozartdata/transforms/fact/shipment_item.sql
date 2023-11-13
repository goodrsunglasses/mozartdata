SELECT
  shipmentnumber,
  item,
  expectedrate,
  quantitybilled,
  quantityexpected,
  quantityreceived,
  quantityremaining,
  receivinglocation,
  shipmentitemamount,
  totalunitcost,
  unitlandedcost
FROM
  fact.shipment_item_detail
WHERE
  shipment_id_ns = 320