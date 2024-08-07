WITH
  cleaned_list AS (
    SELECT
      CASE
        WHEN appears_on_your_statement_as LIKE 'FACEBK%' THEN 'FACEBOOK'
        WHEN appears_on_your_statement_as LIKE 'GOOGL%' THEN 'GOOGLE'
        WHEN appears_on_your_statement_as LIKE 'SERATO%' THEN 'SERATO DJ PRO'
        WHEN appears_on_your_statement_as LIKE 'SNAP%' THEN 'SNAP INC'
        WHEN appears_on_your_statement_as LIKE 'TIKTOK%' THEN 'TIKTOK'
        WHEN appears_on_your_statement_as LIKE 'USPS STAMPS%' THEN 'USA Postal Service'
        WHEN appears_on_your_statement_as LIKE '%ELK MARKETING%' THEN 'ELK MARKETING'
        WHEN appears_on_your_statement_as LIKE '%ADOBE%' THEN 'ADOBE'
        WHEN appears_on_your_statement_as LIKE '%GOOGLE%' THEN 'GOOGLE'
        WHEN appears_on_your_statement_as LIKE '%AMERICAN EXPRESS%' THEN 'AMERICAN EXPRESS'
        WHEN appears_on_your_statement_as LIKE '%APPLE%' THEN 'APPLE'
        WHEN appears_on_your_statement_as LIKE '%AT&T%' THEN 'AT&T'
        WHEN appears_on_your_statement_as LIKE '%ATHENS SERVICES%' THEN 'ATHENS SERVICES'
        WHEN appears_on_your_statement_as LIKE '%SNAP INC%' THEN 'Snap Inc'
        WHEN appears_on_your_statement_as LIKE '%B&H PHOTO VIDEO%' THEN 'B&H Photo Video'
        WHEN appears_on_your_statement_as LIKE '%B4WV%' THEN 'B4WV'
        WHEN appears_on_your_statement_as LIKE '%BILL.COM%' THEN 'BILL.COM'
        WHEN appears_on_your_statement_as LIKE '%CLEAN.IO%' THEN 'Clean.io'
        WHEN appears_on_your_statement_as LIKE '%CLOUD%' THEN 'Cloud'
        WHEN appears_on_your_statement_as LIKE '%D&S SECURITY, INC.%' THEN 'D&S Security, Inc.'
        WHEN appears_on_your_statement_as LIKE '%TIKTOK%' THEN 'TIKTOK'
        WHEN appears_on_your_statement_as LIKE '%ATTENTIVE%' THEN 'ATTENTIVE'
        WHEN appears_on_your_statement_as LIKE '%DROPBOX%' THEN 'DROPBOX'
        WHEN appears_on_your_statement_as LIKE '%DIGIOH%' THEN 'DIGIOH'
        WHEN appears_on_your_statement_as LIKE '%ENDICIA%' THEN 'ENDICIA'
        WHEN appears_on_your_statement_as LIKE '%EXPERIAN%' THEN 'EXPERIAN'
        WHEN appears_on_your_statement_as LIKE '%FACEBOOK%' THEN 'Facebook'
        WHEN appears_on_your_statement_as LIKE '%FEDEX%' THEN 'FEDEX'
        WHEN appears_on_your_statement_as LIKE '%GLEW.IO%' THEN 'Glew.io'
        WHEN appears_on_your_statement_as LIKE '%DRIFT.COM, INC.%' THEN 'Drift.com, Inc.'
        WHEN appears_on_your_statement_as LIKE '%GSUITE%' THEN 'Gsuite'
        WHEN appears_on_your_statement_as LIKE '%KLAVIYO SOFTWARE%' THEN 'KLAVIYO Software'
        WHEN appears_on_your_statement_as LIKE '%IFP VENTURES LLC%' THEN 'IFP Ventures LLC'
        WHEN appears_on_your_statement_as LIKE '%HOTJAR%' THEN 'HOTJAR'
        WHEN appears_on_your_statement_as LIKE '%ULINE SHIP SUPPLIES%' THEN 'ULINE SHIP SUPPLIES'
        WHEN appears_on_your_statement_as LIKE '%UPS%' THEN 'UPS'
        WHEN appears_on_your_statement_as LIKE '%US CORP%' THEN 'US Corp'
        WHEN appears_on_your_statement_as LIKE '%USA POSTAL SERVICE%' THEN 'USA Postal Service'
        WHEN appears_on_your_statement_as LIKE '%VERIZON WIRELESS%' THEN 'Verizon Wireless'
        WHEN appears_on_your_statement_as LIKE '%WAVVE%' THEN 'Wavve'
        WHEN appears_on_your_statement_as LIKE '%NOUNPROJECT%' THEN 'NOUNPROJECT'
        WHEN appears_on_your_statement_as LIKE '%PIPEDRIVE%' THEN 'PIPEDRIVE'
        WHEN appears_on_your_statement_as LIKE '%ZENDESK INC.%' THEN 'ZenDesk Inc.'
        WHEN appears_on_your_statement_as LIKE '%AD AGE%' THEN 'AD AGE'
        WHEN appears_on_your_statement_as LIKE '%LINKEDIN%' THEN 'LINKEDIN'
        WHEN appears_on_your_statement_as LIKE '%CODECADEMY%' THEN 'CODECADEMY'
        WHEN appears_on_your_statement_as LIKE '%YOTPO.COM%' THEN 'YOTPO.COM'
        WHEN appears_on_your_statement_as LIKE '%CHAT GPT%' THEN 'Chat GPT'
        WHEN appears_on_your_statement_as LIKE '%HEATMAP%' THEN 'HEATMAP'
        WHEN appears_on_your_statement_as LIKE '%PANTONE%' THEN 'PANTONE'
        WHEN appears_on_your_statement_as LIKE '%PICS%' THEN 'PICS'
        WHEN appears_on_your_statement_as LIKE '%EXPENSIFY%' THEN 'Expensify'
        WHEN appears_on_your_statement_as LIKE '%FIGMA%' THEN 'FIGMA'
        WHEN appears_on_your_statement_as LIKE '%LASTPASS.COM%' THEN 'LastPass.com'
        WHEN appears_on_your_statement_as LIKE '%GITHUB%' THEN 'GITHUB'
        WHEN appears_on_your_statement_as LIKE '%JETBRAINS%' THEN 'JETBRAINS'
        WHEN appears_on_your_statement_as LIKE '%AMAZON.COM-ADS%' THEN 'Amazon.com-Ads'
        WHEN appears_on_your_statement_as LIKE '%DOCUSIGN%' THEN 'Docusign'
        WHEN appears_on_your_statement_as LIKE '%EASYPOST%' THEN 'Easypost'
        WHEN appears_on_your_statement_as LIKE '%PIPE17.COM%' THEN 'PIPE17.COM'
        ELSE appears_on_your_statement_as
      END AS clean_merchant,
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
  *
FROM
  cleaned_list