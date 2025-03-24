SELECT * FROM (
    SELECT 'GA' AS code, 'Lower 48 (Continental U.S.)' AS region UNION ALL
    SELECT 'FL', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'CA', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'AZ', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'BC', 'Canada' UNION ALL
    SELECT 'IL', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'MT', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'WA', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'SD', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'KS', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'ND', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'MS', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'ID', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'OH', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'WV', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'NB', 'Canada' UNION ALL
    SELECT 'OK', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'SK', 'Canada' UNION ALL
    SELECT 'VI', 'U.S. Territories (U.S. Virgin Islands)' UNION ALL
    SELECT 'Newfoundland and Labrador', 'Canada' UNION ALL
    SELECT 'NH', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'NY', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'DE', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'NS', 'Canada' UNION ALL
    SELECT 'AA', 'Military (APO/FPO/DPO)' UNION ALL
    SELECT 'NC', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'MO', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'AL', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'PR', 'U.S. Territories (Puerto Rico)' UNION ALL
    SELECT 'CT', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'MI', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'VA', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'CO', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'MD', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'NE', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'DC', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'TN', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'OR', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'SC', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'AK', 'Alaska (Non-Contiguous U.S.)' UNION ALL
    SELECT 'IN', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'IA', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'VT', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'PA', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'MN', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'QC', 'Canada' UNION ALL
    SELECT 'WY', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'NL', 'Canada' UNION ALL
    SELECT 'AB', 'Canada' UNION ALL
    SELECT 'RI', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'Québec', 'Canada' UNION ALL
    SELECT 'HI', 'Hawaii (Non-Contiguous U.S.)' UNION ALL
    SELECT 'YT', 'Canada' UNION ALL
    SELECT '不列颠哥伦比亚省', 'Canada (British Columbia)' UNION ALL
    SELECT 'ME', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'KY', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'PE', 'Canada' UNION ALL
    SELECT 'GU', 'U.S. Territories (Guam)' UNION ALL
    SELECT 'NT', 'Canada' UNION ALL
    SELECT 'NU', 'Canada' UNION ALL
    SELECT 'AP', 'Military (APO/FPO/DPO)' UNION ALL
    SELECT 'TX', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'MA', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'MB', 'Canada' UNION ALL
    SELECT 'ON', 'Canada' UNION ALL
    SELECT 'UT', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'LA', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'AE', 'Military (APO/FPO/DPO)' UNION ALL
    SELECT 'AR', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'NJ', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'NV', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'NM', 'Lower 48 (Continental U.S.)' UNION ALL
    SELECT 'WI', 'Lower 48 (Continental U.S.)'
) AS shipping_regions;