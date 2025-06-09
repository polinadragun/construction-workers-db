CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_verification_status ON profiles(verification_status_code);
CREATE INDEX idx_profiles_avg_rating ON profiles(avg_rating);


CREATE INDEX idx_publications_creator_id ON publications(creator_id);
CREATE INDEX idx_publications_status ON publications(publication_status_code);
CREATE INDEX idx_publications_deadline ON publications(deadline);
CREATE INDEX idx_publications_created_at ON publications(created_at);
CREATE INDEX idx_publications_type ON publications(publication_type);

CREATE INDEX idx_tenders_publication_id ON tenders(publication_id);
CREATE INDEX idx_tenders_submission_deadline ON tenders(submission_deadline);
CREATE INDEX idx_tenders_min_experience ON tenders(min_experience_years);
CREATE INDEX idx_orders_publication_id ON orders(publication_id);

CREATE INDEX idx_tender_bids_tender_id ON tender_bids(tender_id);
CREATE INDEX idx_tender_bids_bidder_id ON tender_bids(bidder_id);
CREATE INDEX idx_tender_bids_status ON tender_bids(bid_status_code);
CREATE INDEX idx_tender_bids_total_score ON tender_bids(total_score);
CREATE INDEX idx_order_bids_order_id ON order_bids(order_id);
CREATE INDEX idx_order_bids_bidder_id ON order_bids(bidder_id);

CREATE INDEX idx_user_specializations_user_id ON user_specializations(user_id);
CREATE INDEX idx_user_specializations_spec_code ON user_specializations(spec_code);
CREATE INDEX idx_publication_specializations_pub_id ON publication_specializations(publication_id);
CREATE INDEX idx_publication_regions_pub_id ON publication_regions(publication_id);
CREATE INDEX idx_user_regions_user_id ON user_regions(user_id);

CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_reviewer_id ON reviews(reviewer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

CREATE INDEX idx_portfolio_projects_profile_id ON portfolio_projects(profile_id);
CREATE INDEX idx_portfolio_projects_dates ON portfolio_projects(start_date, end_date);