WITH
  expensify_split AS (
    SELECT DISTINCT
      gl_tran.transaction_id_ns,
      gl_tran.transaction_number_ns,
      gl_tran.net_amount,
      gl_tran.department,
      gl_tran.transaction_date,
      gl_tran.memo,
      SPLIT(gl_tran.memo, '|') AS parts,
    FROM
      fact.gl_transaction gl_tran
      LEFT OUTER JOIN netsuite.transaction tran ON tran.id = gl_tran.transaction_id_ns
    WHERE
      transaction_id_ns = 23886919
      AND custbody_createdfrom_expensify IS NOT NULL
  )
SELECT
  expensify_split.*,
  TRIM(parts[0]) AS email,
  replace(TRIM(REPLACE(parts[3], 'Expense:', '')), '"', '') AS expense --had to do this because it puts double quotes, idk why but dont have time to fix it rn
FROM
  expensify_split