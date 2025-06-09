INSERT INTO publication_specializations (publication_id, spec_code)
VALUES (?, ?)
ON CONFLICT DO NOTHING