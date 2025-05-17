INSERT INTO e_signature_verifications (id, profile_id, verification_status, signature_provider, verified_at)
VALUES (?, ?, ?, ?, now())