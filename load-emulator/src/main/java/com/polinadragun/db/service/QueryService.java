package com.polinadragun.db.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

@Service
public class QueryService {

    private final JdbcTemplate jdbcTemplate;
    private final Map<String, String> queries;
    private final List<String> queryKeys;
    private final int minExecutions;
    private final int maxExecutions;

    public QueryService(
            JdbcTemplate jdbcTemplate,
            @Value("${load.simulation.min:1}") int minExecutions,
            @Value("${load.simulation.max:5}") int maxExecutions) {
        this.jdbcTemplate = jdbcTemplate;
        this.minExecutions = minExecutions;
        this.maxExecutions = maxExecutions;

        this.queries = Map.ofEntries(
                Map.entry("profiles_with_roles", """
        /* profiles_with_roles */
        SELECT p.id AS profile_id, u.full_name, p.avg_rating,
               vsc.description AS verification_status, r.role_code
        FROM profiles p
        JOIN users u ON p.user_id = u.id
        JOIN verification_status_codes vsc ON p.verification_status_code = vsc.code
        JOIN user_roles ur ON ur.user_id = u.id
        JOIN roles r ON ur.role_code = r.role_code
    """),
                Map.entry("tender_bid_scores", """
        /* tender_bid_scores */
        SELECT tb.id AS bid_id, u.full_name AS bidder, p.title AS publication_title,
               tb.total_score, COUNT(tbe.id) AS evaluations_count
        FROM tender_bids tb
        JOIN users u ON tb.bidder_id = u.id
        JOIN tenders t ON tb.tender_id = t.id
        JOIN publications p ON t.publication_id = p.id
        LEFT JOIN tender_bid_evaluations tbe ON tb.id = tbe.tender_bid_id
        GROUP BY tb.id, u.full_name, p.title, tb.total_score
    """),
                Map.entry("reviews_with_profiles", """
        /* reviews_with_profiles */
        SELECT r.id AS review_id, reviewer.full_name AS reviewer_name,
               reviewed.full_name AS reviewed_name, r.rating, p.avg_rating
        FROM reviews r
        JOIN users reviewer ON r.reviewer_id = reviewer.id
        JOIN users reviewed ON r.user_id = reviewed.id
        JOIN profiles p ON p.user_id = reviewed.id
        WHERE r.rating >= 4
    """),
                Map.entry("publication_meta", """
        /* publication_meta */
        SELECT pub.id AS publication_id, pub.title, ps.spec_code, pr.region_code,
               pubsc.description AS status_description
        FROM publications pub
        JOIN publication_specializations ps ON pub.id = ps.publication_id
        JOIN publication_regions pr ON pub.id = pr.publication_id
        JOIN publication_status_codes pubsc ON pub.publication_status_code = pubsc.code
    """),
                Map.entry("tender_details", """
        /* tender_details */
        SELECT t.id AS tender_id, pub.title, u.full_name, p.avg_rating, t.tender_type
        FROM tenders t
        JOIN publications pub ON t.publication_id = pub.id
        JOIN tender_bids tb ON tb.tender_id = t.id
        JOIN users u ON tb.bidder_id = u.id
        JOIN profiles p ON p.user_id = u.id
    """),
                Map.entry("profile_details_by_type", """
        /* profile_details_by_type */
        SELECT p.id AS profile_id, u.full_name, lpt.name AS legal_type,
               cpd.company_name, gpd.inn AS gov_inn, ipd.fio AS ip_fio, ppd.inn AS person_inn
        FROM profiles p
        JOIN users u ON p.user_id = u.id
        JOIN legal_profile_types lpt ON p.legal_type_code = lpt.legal_type_code
        LEFT JOIN company_profile_details cpd ON p.id = cpd.profile_id
        LEFT JOIN gov_profile_details gpd ON p.id = gpd.profile_id
        LEFT JOIN ip_profile_details ipd ON p.id = ipd.profile_id
        LEFT JOIN person_profile_details ppd ON p.id = ppd.profile_id
    """),
                Map.entry("user_project_stats", """
        /* user_project_stats */
        SELECT u.full_name, COUNT(pp.id) AS project_count, p.avg_rating
        FROM users u
        JOIN profiles p ON p.user_id = u.id
        JOIN portfolio_projects pp ON pp.profile_id = p.id
        GROUP BY u.full_name, p.avg_rating
        ORDER BY project_count DESC
    """),
                Map.entry("verification_documents", """
        /* verification_documents */
        SELECT vd.document_type, vd.document_url, ev.signature_provider,
               ev.verified_at, vs.description AS verification_status
        FROM verification_documents vd
        JOIN e_signature_verifications ev ON vd.profile_id = ev.profile_id
        JOIN verification_status_codes vs ON vd.verification_status_code = vs.code
    """),
                Map.entry("tender_bid_documents_and_scores", """
        /* tender_bid_documents_and_scores */
        SELECT tb.id AS bid_id, u.full_name, bd.file_url, bd.file_type,
               be.score, bs.description AS bid_status
        FROM tender_bids tb
        JOIN users u ON tb.bidder_id = u.id
        LEFT JOIN tender_bid_documents bd ON tb.id = bd.tender_bid_id
        LEFT JOIN tender_bid_evaluations be ON tb.id = be.tender_bid_id
        JOIN bid_status_codes bs ON tb.bid_status_code = bs.code
    """),
                Map.entry("order_details", """
        /* order_details */
        SELECT o.id AS order_id, pub.title, u.full_name,
               pr.region_code, ps.spec_code
        FROM orders o
        JOIN publications pub ON o.publication_id = pub.id
        JOIN users u ON pub.creator_id = u.id
        LEFT JOIN publication_regions pr ON pub.id = pr.publication_id
        LEFT JOIN publication_specializations ps ON pub.id = ps.publication_id
    """),
                Map.entry("publication_tenders_detailed", """
        /* publication_tenders_detailed */
        SELECT 
            t.id AS tender_id,
            pub.title AS publication_title,
            pub.publication_type,
            pubsc.description AS publication_status,
            u.full_name AS creator_name,
            COUNT(tb.id) AS bids_count
        FROM tenders t
        JOIN publications pub ON t.publication_id = pub.id
        JOIN users u ON pub.creator_id = u.id
        JOIN publication_status_codes pubsc ON pub.publication_status_code = pubsc.code
        LEFT JOIN tender_bids tb ON t.id = tb.tender_id
        WHERE pub.publication_type = 'tender'
        GROUP BY t.id, pub.title, pub.publication_type, pubsc.description, u.full_name
    """),
                Map.entry("order_publication_details", """
        /* order_publication_details */
        SELECT 
            o.id AS order_id,
            pub.title AS publication_title,
            u.full_name AS author_name,
            r.name AS region_name,
            s.name AS specialization_name
        FROM orders o
        JOIN publications pub ON o.publication_id = pub.id
        JOIN users u ON pub.creator_id = u.id
        LEFT JOIN publication_regions pr ON pub.id = pr.publication_id
        LEFT JOIN regions r ON pr.region_code = r.region_code
        LEFT JOIN publication_specializations ps ON pub.id = ps.publication_id
        LEFT JOIN specializations s ON ps.spec_code = s.spec_code
        WHERE pub.publication_type = 'order'
    """)
        );


        this.queryKeys = new ArrayList<>(queries.keySet());
    }

    public void executeRandomizedQueryBatch() {
        String key = queryKeys.get(ThreadLocalRandom.current().nextInt(queryKeys.size()));
        String sql = queries.get(key);
        int executions = ThreadLocalRandom.current().nextInt(minExecutions, maxExecutions + 1);
        System.out.printf("Executing query [%s] %d times%n", key, executions);
        for (int i = 0; i < executions; i++) {
            jdbcTemplate.queryForList(sql);
        }
    }

    public int queryCount() {
        return queries.size();
    }
}
