WITH
  joined AS (
    SELECT
      reference,
      appears_on_your_statement_as,
      card_member,
      DATE,
      amount,
      CASE --The idea with these case whens is to make a boolean that tells us when ON THE BANK statement a transaction is unique in one of two ways, so we can direct join it to NS safely
        WHEN (
          count(amount) over (
            PARTITION BY
              card_member,
              amount
          )
        ) > 1 THEN FALSE
        ELSE TRUE
      END AS unique_amount_per_name,
      CASE
        WHEN (
          count(amount) over (
            PARTITION BY
              card_member,
              amount,
              DATE
          )
        ) > 1 THEN FALSE
        ELSE TRUE
      END AS unique_amount_per_name_per_day,
      'AMEX' AS source
    FROM
      google_sheets.amex_import
    UNION ALL
    SELECT
      transaction_id,
      merchant_name,
      account_given_name,
      post_date,
      amount,
      CASE
        WHEN (
          count(amount) over (
            PARTITION BY
              account_given_name,
              amount
          )
        ) > 1 THEN FALSE
        ELSE TRUE
      END AS unique_amount_per_name,
      CASE
        WHEN (
          count(amount) over (
            PARTITION BY
              account_given_name,
              amount,
              post_DATE
          )
        )  > 1 THEN FALSE
        ELSE TRUE
      END AS unique_amount_per_name_per_day,
      'JPM' AS source
    FROM
      google_sheets.jpmastercard_upload
  )
SELECT
  joined.*,
  Upper(appears_on_your_statement_as) upped,
  CASE
    WHEN upped LIKE 'FACEBK%' THEN 'FACEBOOK'
    WHEN upped LIKE 'GOOGL%' THEN 'GOOGLE'
    WHEN upped LIKE 'SERATO%' THEN 'SERATO DJ PRO'
    WHEN upped LIKE 'SNAP%' THEN 'SNAP INC'
    WHEN upped LIKE 'TIKTOK%' THEN 'TIKTOK'
    WHEN upped LIKE '%DIN TAI FUNG%' THEN 'DIN TAI FUNG'
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
    WHEN upped LIKE '%DOCUSIGN%' THEN 'Docusign'
    WHEN upped LIKE '%EASYPOST%' THEN 'Easypost'
    WHEN upped LIKE '%PIPE17.COM%' THEN 'PIPE17.COM'
    WHEN upped LIKE '%FEDEX%' THEN 'FEDEX'
    WHEN upped LIKE '%SHOPIFY%' THEN 'SHOPIFY'
    WHEN upped LIKE '%ZENDESK%' THEN 'ZenDesk Inc.'
    WHEN upped LIKE '%INTUIT%' THEN 'INTUIT'
    WHEN upped LIKE '%MENLO%' THEN 'FACEBOOK'
    WHEN upped LIKE '%VZWRLSS%' THEN 'Verizon Wireless'
    WHEN upped LIKE '%SPOTIFY%' THEN 'SPOTIFY'
    WHEN upped LIKE '%STAMPS.COM%' THEN 'STAMPS.COM'
    WHEN upped LIKE 'USPS STAMPS%' THEN 'USA Postal Service'
    WHEN upped LIKE 'AUCTANE%' THEN 'SHIPSTATION'
    WHEN upped LIKE 'AMAZON.COM%' THEN 'Amazon.com-Ads'
    WHEN upped LIKE 'PAY.AMAZON.COM%' THEN 'AMAZON PAY'
    WHEN upped LIKE 'CORPORATE FILINGS LLC%' THEN 'CORPORATE FILINGS LLC'
    ELSE NULL
  END AS clean_merchant,
  CASE
    WHEN card_member LIKE 'JANE%' THEN 'JANE WU'
    WHEN card_member = 'ALLIE' THEN 'Allison Lefton'
    WHEN card_member = 'ROBERTO' THEN 'Rob Federic'
    WHEN card_member = 'LAUREN' THEN 'Lauren Larvejo'
    ELSE card_member
  END AS clean_card_member
FROM
  joined