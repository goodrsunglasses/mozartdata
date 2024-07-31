SELECT
  binnumber,
  committedqtyperlocation,
  committedqtyperseriallotnumber,
  committedqtyperseriallotnumberlocation,
  item,
  location,
  quantityavailable,
  quantityonhand,
  quantitypicked,
  date(_fivetran_synced) AS date_synced,
  _fivetran_synced
FROM
  netsuite.inventorybalance balance
order by _FIVETRAN_SYNCED desc