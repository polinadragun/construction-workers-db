INSERT INTO tenders
(id, publication_id, submission_deadline, evaluation_criteria, required_documents, description, contract_security_amount, min_experience_years, warranty_period_months, tender_type)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?::tender_type_enum)