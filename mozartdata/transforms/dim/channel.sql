SELECT
  id AS channel_id_ns,
  name,
  CASE
    WHEN name IN (
      'Specialty',
      'Key Account',
      'Global',
      'Key Account CAN',
      'Specialty CAN'
    ) THEN 'B2B'
    WHEN name IN (
      'Goodr.com',
      'Amazon',
      'Amazon Prime',
      'Cabana',
      'Goodr.com CAN',
      'Prescription'
    ) THEN 'D2C'
    WHEN name IN (
      'Goodrwill.com',
      'Customer Service CAN',
      'Marketing',
      'Co-Brand',
      'Donations',
      'Goodrstock Giveaways',
      'Content Giveaways',
      'Customer Service'
    ) THEN 'INDIRECT'
  END AS customer_category,
  CASE
    WHEN name IN (
      'Specialty',
      'Key Account',
      'Key Account CAN',
      'Specialty CAN'
    ) THEN 'Wholesale'
    WHEN name IN ('Goodr.com', 'Goodr.com CAN') THEN 'Website'
    WHEN name IN ('Amazon', 'Prescription') THEN 'Partners'
    WHEN name IN ('Cabana') THEN 'Retail'
    WHEN name IN ('Global') THEN 'Distribution'
  END AS model
FROM
  netsuite.customrecord_cseg7 channel
ORDER BY
  name