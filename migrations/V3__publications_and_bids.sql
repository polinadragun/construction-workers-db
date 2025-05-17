CREATE TABLE IF NOT EXISTS publications (
    id UUID PRIMARY KEY,
    creator_id UUID NOT NULL,
    publication_status_code VARCHAR(15) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    deadline TIMESTAMP NOT NULL CHECK (deadline > CURRENT_TIMESTAMP),
    created_at TIMESTAMP NOT NULL CHECK (created_at <= CURRENT_TIMESTAMP),
    publication_type publication_type_enum NOT NULL,
    FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (publication_status_code) REFERENCES publication_status_codes(code));

CREATE TABLE IF NOT EXISTS publication_specializations (
    publication_id UUID NOT NULL,
    spec_code VARCHAR(15) NOT NULL,
    PRIMARY KEY (publication_id, spec_code),
    FOREIGN KEY (publication_id) REFERENCES publications(id) ON DELETE CASCADE,
    FOREIGN KEY (spec_code) REFERENCES specializations(spec_code) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS publication_regions (
    publication_id UUID NOT NULL,
    region_code SMALLINT NOT NULL,
    PRIMARY KEY (publication_id, region_code),
    FOREIGN KEY (publication_id) REFERENCES publications(id) ON DELETE CASCADE,
    FOREIGN KEY (region_code) REFERENCES regions(region_code) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS publication_mediafiles (
    id UUID PRIMARY KEY,
    publication_id UUID NOT NULL,
    file_url VARCHAR(250) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL CHECK (uploaded_at <= CURRENT_TIMESTAMP),
    FOREIGN KEY (publication_id) REFERENCES publications(id) ON DELETE CASCADE);


CREATE TABLE IF NOT EXISTS tenders (
    id UUID PRIMARY KEY,
    publication_id UUID NOT NULL,
    submission_deadline TIMESTAMP NOT NULL CHECK ( submission_deadline > CURRENT_TIMESTAMP),
    evaluation_criteria TEXT NOT NULL,
    required_documents TEXT NOT NULL,
    description TEXT NOT NULL,
    contract_security_amount DECIMAL(15,2) NOT NULL,
    min_experience_years INT NOT NULL,
    warranty_period_months INT NOT NULL,
    tender_type tender_type_enum NOT NULL,
    FOREIGN KEY (publication_id) REFERENCES publications(id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY,
    publication_id UUID NOT NULL,
    required_delivery_date TIMESTAMP NOT NULL,
    description TEXT NOT NULL,
    FOREIGN KEY (publication_id) REFERENCES publications(id) ON DELETE CASCADE);


CREATE TABLE IF NOT EXISTS tender_bids (
    id UUID PRIMARY KEY,
    tender_id UUID NOT NULL,
    bidder_id UUID NOT NULL,
    bid_status_code VARCHAR(15) NOT NULL REFERENCES bid_status_codes(code),
    proposal TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL CHECK (created_at <= CURRENT_TIMESTAMP),
    warranty_period_months INT NOT NULL,
    completion_time_days INT NOT NULL,
    total_score DECIMAL(5,2) DEFAULT 0.0,
    FOREIGN KEY (tender_id) REFERENCES tenders(id) ON DELETE CASCADE,
    FOREIGN KEY (bidder_id) REFERENCES users(id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS tender_bid_documents (
    id UUID PRIMARY KEY,
    tender_bid_id UUID NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (tender_bid_id) REFERENCES tender_bids(id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS tender_bid_evaluations (
    id UUID PRIMARY KEY,
    tender_bid_id UUID NOT NULL,
    evaluator_name VARCHAR(50) NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    comment TEXT,
    created_at TIMESTAMP NOT NULL CHECK (created_at <= CURRENT_TIMESTAMP),
    FOREIGN KEY (tender_bid_id) REFERENCES tender_bids(id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS order_bids (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL,
    bidder_id UUID NOT NULL,
    bid_status_code VARCHAR(15) NOT NULL REFERENCES bid_status_codes(code),
    created_at TIMESTAMP NOT NULL CHECK (created_at <= CURRENT_TIMESTAMP),
    additional_comment TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (bidder_id) REFERENCES users(id) ON DELETE CASCADE);

CREATE FUNCTION update_bid_score() RETURNS TRIGGER AS $$
BEGIN
    UPDATE tender_bids
    SET
        total_score = (
            SELECT ROUND(AVG(ev.score)::numeric, 2)
            FROM tender_bid_evaluations ev
            WHERE ev.tender_bid_id = NEW.tender_bid_id
        )
    WHERE id = NEW.tender_bid_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_profile_rating AFTER INSERT ON tender_bid_evaluations
    FOR EACH ROW EXECUTE FUNCTION update_bid_score();
