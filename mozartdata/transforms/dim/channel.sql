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
  END AS customer_category
FROM
  netsuite.customrecord_cseg7 channel
ORDER BY
  name