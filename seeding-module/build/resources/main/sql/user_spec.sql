INSERT INTO user_specializations (user_id, spec_code)
VALUES (?, ?)
ON CONFLICT DO NOTHING