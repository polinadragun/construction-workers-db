INSERT INTO publication_regions (publication_id, region_code)
VALUES (?, ?)
ON CONFLICT DO NOTHING