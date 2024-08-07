WITH
  cleaned_list AS (
    SELECT
      Upper(appears_on_your_statement_as) upped,
      CASE
        WHEN upped LIKE 'FACEBK%' THEN 'FACEBOOK'
        WHEN upped LIKE 'GOOGL%' THEN 'GOOGLE'
        WHEN upped LIKE 'SERATO%' THEN 'SERATO DJ PRO'
        WHEN upped LIKE 'SNAP%' THEN 'SNAP INC'
        WHEN upped LIKE 'TIKTOK%' THEN 'TIKTOK'
        WHEN upped LIKE '%ELK MARKETING%' THEN 'ELK MARKETING'
        WHEN upped LIKE '%ADOBE%' THEN 'ADOBE'
        WHEN upped LIKE '%AMERICAN EXPRESS%' THEN 'AMERICAN EXPRESS'
        WHEN upped LIKE '%APPLE%' THEN 'APPLE'
        WHEN upped LIKE '%AT&T%' THEN 'AT&T'
        WHEN upped LIKE '%ATHENS SERVICES%' THEN 'ATHENS SERVICES'
        WHEN upped LIKE '%SNAP INC%' THEN 'Snap Inc'
        WHEN upped LIKE '%B&H PHOTO VIDEO%' THEN 'B&H Photo Video'
        WHEN upped LIKE '%B4WV%' THEN 'B4WV'
        WHEN upped LIKE '%BILL.COM%' THEN 'BILL.COM'
        WHEN upped LIKE '%CLEAN.IO%' THEN 'Clean.io'
        WHEN upped LIKE '%CLOUD%' THEN 'Cloud'
        WHEN upped LIKE '%D&S SECURITY, INC.%' THEN 'D&S Security, Inc.'
        WHEN upped LIKE '%TIKTOK%' THEN 'TIKTOK'
        WHEN upped LIKE '%ATTENTIVE%' THEN 'ATTENTIVE'
        WHEN upped LIKE '%DROPBOX%' THEN 'DROPBOX'
        WHEN upped LIKE '%DIGIOH%' THEN 'DIGIOH'
        WHEN upped LIKE '%EXPERIAN%' THEN 'EXPERIAN'
        WHEN upped LIKE '%FACEBOOK%' THEN 'Facebook'
        WHEN upped LIKE '%GLEW.IO%' THEN 'Glew.io'
        WHEN upped LIKE '%DRIFT.COM, INC.%' THEN 'Drift.com, Inc.'
        WHEN upped LIKE '%GSUITE%' THEN 'Gsuite'
        WHEN upped LIKE '%KLAVIYO SOFTWARE%' THEN 'KLAVIYO Software'
        WHEN upped LIKE '%IFP VENTURES LLC%' THEN 'IFP Ventures LLC'
        WHEN upped LIKE '%HOTJAR%' THEN 'HOTJAR'
        WHEN upped LIKE '%ULINE SHIP SUPPLIES%' THEN 'ULINE SHIP SUPPLIES'
        WHEN upped LIKE '%UPS%' THEN 'UPS'
        WHEN upped LIKE '%US CORP%' THEN 'US Corp'
        WHEN upped LIKE '%VERIZON WIRELESS%' THEN 'Verizon Wireless'
        WHEN upped LIKE '%WAVVE%' THEN 'Wavve'
        WHEN upped LIKE '%NOUNPROJECT%' THEN 'NOUNPROJECT'
        WHEN upped LIKE '%PIPEDRIVE%' THEN 'PIPEDRIVE'
        WHEN upped LIKE '%ZENDESK INC.%' THEN 'ZenDesk Inc.'
        WHEN upped LIKE '%AD AGE%' THEN 'AD AGE'
        WHEN upped LIKE '%LINKEDIN%' THEN 'LINKEDIN'
        WHEN upped LIKE '%CODECADEMY%' THEN 'CODECADEMY'
        WHEN upped LIKE '%YOTPO.COM%' THEN 'YOTPO.COM'
        WHEN upped LIKE '%CHAT GPT%' THEN 'Chat GPT'
        WHEN upped LIKE '%HEATMAP%' THEN 'HEATMAP'
        WHEN upped LIKE '%PANTONE%' THEN 'PANTONE'
        WHEN upped LIKE '%PICS%' THEN 'PICS'
        WHEN upped LIKE '%EXPENSIFY%' THEN 'Expensify'
        WHEN upped LIKE '%FIGMA%' THEN 'FIGMA'
        WHEN upped LIKE '%LASTPASS.COM%' THEN 'LastPass.com'
        WHEN upped LIKE '%GITHUB%' THEN 'GITHUB'
        WHEN upped LIKE '%JETBRAINS%' THEN 'JETBRAINS'
        WHEN upped LIKE '%AMAZON.COM-ADS%' THEN 'Amazon.com-Ads'
        WHEN upped LIKE '%DOCUSIGN%' THEN 'Docusign'
        WHEN upped LIKE '%EASYPOST%' THEN 'Easypost'
        WHEN upped LIKE '%PIPE17.COM%' THEN 'PIPE17.COM'
        WHEN upped LIKE '%AMAZON%' THEN 'AMAZON'
        WHEN upped LIKE '%FEDEX%' THEN 'FEDEX'
        WHEN upped LIKE '%SHOPIFY%' THEN 'SHOPIFY'
        WHEN upped LIKE '%ZENDESK%' THEN 'ZENDESK'
        WHEN upped LIKE '%INTUIT%' THEN 'INTUIT'
        WHEN upped LIKE '%MENLO%' THEN 'FACEBOOK'
        WHEN upped LIKE '%VZWRLSS%' THEN 'Verizon Wireless'
        WHEN upped LIKE '%SPOTIFY%' THEN 'SPOTIFY'
        WHEN upped LIKE '%STAMPS.COM%' THEN 'STAMPS.COM'
        WHEN upped LIKE 'USPS STAMPS%' THEN 'USA Postal Service'
        ELSE NULL
      END AS clean_merchant,
      reference,
      appears_on_your_statement_as,
      amount,
      DATE
    FROM
      google_sheets.amex_import
    WHERE
      card_member = 'JANE WU'
    ORDER BY
      clean_merchant
  )
SELECT
  reference,
  appears_on_your_statement_as,
  clean_merchant,
  DATE,
  amount,
  Vendor,
  GL,
  Internal,
  Description,
  Department,
  Department_id,
FROM
  cleaned_list
  LEFT OUTER JOIN google_sheets.amex_mapping map ON upper(map.vendor) = upper(cleaned_list.clean_merchant)