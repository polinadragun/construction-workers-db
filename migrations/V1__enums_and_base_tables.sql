CREATE TYPE publication_type_enum AS ENUM ('tender', 'order');
CREATE TYPE tender_type_enum AS ENUM ('open', 'closed', 'invitation');

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    email VARCHAR(254) NOT NULL UNIQUE CHECK (email LIKE '%@%'),
    password_hash VARCHAR(128) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(15) CHECK (char_length(contact_phone) BETWEEN 7 AND 15));

CREATE TABLE IF NOT EXISTS roles (
    role_code VARCHAR(15) PRIMARY KEY,
    requires_legal_profiles BOOLEAN NOT NULL DEFAULT FALSE);

CREATE TABLE IF NOT EXISTS regions (
    region_code SMALLINT PRIMARY KEY CHECK (region_code > 0),
    name VARCHAR(100) NOT NULL);

CREATE TABLE IF NOT EXISTS specializations (
    spec_code VARCHAR(15) PRIMARY KEY,
    name VARCHAR(100) NOT NULL);

CREATE TABLE IF NOT EXISTS publication_status_codes (
    code VARCHAR(15) PRIMARY KEY,
    description VARCHAR(100) NOT NULL);

CREATE TABLE IF NOT EXISTS verification_status_codes (
    code VARCHAR(15) PRIMARY KEY,
    description VARCHAR(100) NOT NULL);

CREATE TABLE IF NOT EXISTS legal_profile_types (
    legal_type_code VARCHAR(15) PRIMARY KEY,
    name VARCHAR(50) NOT NULL);

CREATE TABLE IF NOT EXISTS bid_status_codes (
    code VARCHAR(15) PRIMARY KEY,
    description VARCHAR(100) NOT NULL);
