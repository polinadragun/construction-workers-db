CREATE TABLE publications_partitioned (
    id UUID NOT NULL,
    creator_id UUID NOT NULL,
    publication_status_code VARCHAR(15) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    deadline TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    publication_type publication_type_enum NOT NULL,
    PRIMARY KEY (id, publication_type)
                                      ) PARTITION BY LIST (publication_type);

CREATE TABLE publications_tender PARTITION OF publications_partitioned
    FOR VALUES IN ('tender');

CREATE TABLE publications_order PARTITION OF publications_partitioned
    FOR VALUES IN ('order');

INSERT INTO publications_partitioned
SELECT * FROM publications;

BEGIN;

ALTER TABLE publications RENAME TO publications_old;
ALTER TABLE publications_partitioned RENAME TO publications;

COMMIT;