CREATE TABLE IF NOT EXISTS user_roles (
    user_id UUID NOT NULL,
    role_code VARCHAR(15) NOT NULL ,
    PRIMARY KEY (user_id, role_code),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_code) REFERENCES roles(role_code) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS user_specializations (
    user_id UUID NOT NULL,
    spec_code VARCHAR(15) NOT NULL,
    PRIMARY KEY (user_id, spec_code),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (spec_code) REFERENCES specializations(spec_code) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS user_regions (
    user_id UUID NOT NULL,
    region_code SMALLINT NOT NULL,
    PRIMARY KEY (user_id, region_code),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (region_code) REFERENCES regions(region_code) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    legal_type_code VARCHAR(15) NOT NULL,
    verification_status_code VARCHAR(15) NOT NULL,
    verification_comment VARCHAR(250),
    created_at TIMESTAMP NOT NULL CHECK (created_at <= CURRENT_TIMESTAMP),
    updated_at TIMESTAMP NOT NULL CHECK (updated_at <= CURRENT_TIMESTAMP),
    avg_rating DECIMAL(3,2) DEFAULT 0.0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (legal_type_code) REFERENCES legal_profile_types(legal_type_code),
    FOREIGN KEY (verification_status_code) REFERENCES verification_status_codes(code),
    CHECK (created_at <= updated_at));

CREATE TABLE IF NOT EXISTS gov_profile_details (
    id UUID PRIMARY KEY,
    profile_id UUID NOT NULL,
    inn VARCHAR(12) NOT NULL,
    kpp VARCHAR(9) NOT NULL,
    ogrn VARCHAR(13) NOT NULL,
    representative_fio VARCHAR(255) NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS company_profile_details (
    id UUID PRIMARY KEY,
    profile_id UUID NOT NULL,
    inn VARCHAR(12) NOT NULL,
    ogrn VARCHAR(13) NOT NULL,
    kpp VARCHAR(9) NOT NULL,
    sro_certificate_number VARCHAR(50),
    company_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS ip_profile_details (
    id UUID PRIMARY KEY,
    profile_id UUID NOT NULL,
    inn VARCHAR(12) NOT NULL,
    ogrnip VARCHAR(15) NOT NULL,
    fio VARCHAR(255) NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS person_profile_details (
    id UUID PRIMARY KEY,
    profile_id UUID NOT NULL,
    inn VARCHAR(12) NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS verification_documents (
    id UUID PRIMARY KEY,
    profile_id UUID NOT NULL,
    verification_status_code VARCHAR(15) NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    document_url VARCHAR(250) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL CHECK (uploaded_at <= CURRENT_TIMESTAMP),
    verification_comment VARCHAR(250),
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (verification_status_code) REFERENCES verification_status_codes(code));

CREATE TABLE IF NOT EXISTS e_signature_verifications (
    id UUID PRIMARY KEY,
    profile_id UUID NOT NULL,
    verification_status VARCHAR(15) NOT NULL,
    signature_provider VARCHAR(100) NOT NULL,
    verified_at TIMESTAMP CHECK (verified_at <= CURRENT_TIMESTAMP),
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (verification_status) REFERENCES verification_status_codes(code));