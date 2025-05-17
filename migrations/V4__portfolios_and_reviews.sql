CREATE TABLE IF NOT EXISTS portfolio_projects (
    id UUID PRIMARY KEY,
    profile_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
    CHECK (start_date < end_date));

CREATE TABLE IF NOT EXISTS project_mediafiles (
    id UUID PRIMARY KEY,
    portfolio_project_id UUID NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    FOREIGN KEY (portfolio_project_id) REFERENCES portfolio_projects(id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY,
    reviewer_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL CHECK (created_at <= CURRENT_TIMESTAMP),
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE);

CREATE OR REPLACE FUNCTION update_profile_rating() RETURNS TRIGGER AS $$
    BEGIN
        UPDATE profiles
        SET
        avg_rating = (
            SELECT ROUND(AVG(r.rating)::numeric, 2)
            FROM reviews r
            WHERE r.user_id = NEW.user_id
        )
        WHERE user_id = NEW.user_id;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_profile_rating AFTER INSERT ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_profile_rating();
