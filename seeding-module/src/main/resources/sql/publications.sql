INSERT INTO publications (id, creator_id, publication_status_code, title, description, deadline, created_at, publication_type)
VALUES (?, ?, ?, ?, ?, ?, ?, ?::publication_type_enum)