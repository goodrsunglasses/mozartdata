--- grab all the order numbers
WITH
  defective_ids AS (
    SELECT
      order_id_ns
    FROM
      fact.gl_transaction
    WHERE
      account_number = 4220
  ),
  by_order AS (
    SELECT
      gl.order_id_edw,
      gl.order_id_ns AS returnlogic_order_id_ns,
      gl.transaction_number_ns,
      gl.channel,
      gl.transaction_date,
      gl.posting_period,
      gl.net_amount AS cogs,
      p.display_name,
      p.sku
    FROM
      fact.gl_transaction gl
      LEFT JOIN dim.product p ON p.item_id_ns = gl.item_id_ns
      INNER JOIN defective_ids id ON id.order_id_ns = gl.order_id_ns
    WHERE
      gl.account_number = 5000
      AND posting_flag
      AND posting_period LIKE '%2024'
  )
SELECT
  channel,
  posting_period,
  sku,
  display_name,
  sum(cogs) AS cogs
FROM
  by_order
GROUP BY
  ALL
ORDER BY
  posting_period,
  channel,
  sku