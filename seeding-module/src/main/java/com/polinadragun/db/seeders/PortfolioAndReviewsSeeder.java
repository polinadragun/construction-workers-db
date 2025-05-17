package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Version(1)
public class PortfolioAndReviewsSeeder extends BasicFakerSeeder {

    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        seedPortfolioProjects(connection);
        seedProjectMediaFiles(connection);
        seedReviews(connection);

    }

    public void seedPortfolioProjects(Connection conn) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("portfolio_projects.sql");

        PreparedStatement Statement = conn.prepareStatement(sql);
        Statement userStatement = conn.createStatement();
        userStatement.setFetchSize(batchSize);
        ResultSet users = userStatement.executeQuery("SELECT id FROM profiles");
        int profilesWithProjectsCount = 0;

        while (users.next()) {
            UUID profileId = (UUID) users.getObject("id");
            //System.out.println(profileId);
            int projectCount = 1 + random.nextInt(3);

            for (int i = 0; i < projectCount; i++) {
                UUID projectId = UUID.randomUUID();
                String title = faker.lorem().sentence();
                String description = faker.lorem().paragraph();
                LocalDate startDate = LocalDate.now().minusMonths(random.nextInt(12));
                LocalDate endDate = startDate.plusMonths(random.nextInt(12));

                Statement.setObject(1, projectId);
                Statement.setObject(2, profileId);
                Statement.setString(3, title);
                Statement.setString(4, description);
                Statement.setDate(5, Date.valueOf(startDate));

                if (endDate != null && startDate.isBefore(endDate)) {
                    Statement.setDate(6, Date.valueOf(endDate));
                } else {
                    Statement.setNull(6, Types.DATE);
                }

                Statement.addBatch();
            }
            if (++profilesWithProjectsCount % batchSize == 0) {
                Statement.executeBatch();
            }

        }
        Statement.executeBatch();
        System.out.println("Seeded portfolio_projects");
        
    }

    private String randomChoice(String[] array) {
        return array[random.nextInt(array.length)];
    }

    public void seedProjectMediaFiles(Connection conn) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("project_mediafiles.sql");

        PreparedStatement statement = conn.prepareStatement(sql);
        Statement projectStatement = conn.createStatement();
        projectStatement.setFetchSize(batchSize);
        ResultSet projects = projectStatement.executeQuery("SELECT id FROM portfolio_projects");
        int projectsWithMediaFilesCount = 0;

        while (projects.next()) {
            String[] fileTypes = {"image", "video", "document"};

            UUID projectId = (UUID) projects.getObject("id");
            int mediaCount = 1 + random.nextInt(3);

            for (int i = 0; i < mediaCount; i++) {
                UUID mediaId = UUID.randomUUID();

                statement.setObject(1, mediaId);
                statement.setObject(2, projectId);
                statement.setString(3, faker.internet().url());
                statement.setString(4, randomChoice(fileTypes));

                statement.addBatch();
            }
            if (++projectsWithMediaFilesCount % batchSize == 0) {
                statement.executeBatch();
            }
        }
        statement.executeBatch();
        System.out.println("Seeded project_mediafiles");
    }

    public void seedReviews(Connection connection) throws SQLException, IOException {

        String reviewInsertSQL = SqlLoader.loadSql("reviews.sql");

        String publicationQuery = "SELECT id, creator_id FROM publications";

        String bidderQuery = SqlLoader.loadSql("bidders_for_reviews.sql");

        PreparedStatement reviewStatement = connection.prepareStatement(reviewInsertSQL);
        PreparedStatement bidderStatement = connection.prepareStatement(bidderQuery);
        Statement pubStatement = connection.createStatement();
        pubStatement.setFetchSize(batchSize);
        ResultSet pubsRs = pubStatement.executeQuery(publicationQuery);

        int batchCount = 0;

        while (pubsRs.next()) {
            UUID publicationId = (UUID) pubsRs.getObject("id");
            UUID creatorId = (UUID) pubsRs.getObject("creator_id");

            bidderStatement.setObject(1, publicationId);
            try (ResultSet bidderRs = bidderStatement.executeQuery()) {
                if (!bidderRs.next()) continue;

                UUID bidderId = (UUID) bidderRs.getObject("bidder_id");
                if (creatorId.equals(bidderId)) continue;

                UUID reviewId = UUID.randomUUID();
                int rating = random.nextInt(5) + 1;
                String comment = faker.lorem().sentence();
                Timestamp createdAt = Timestamp.valueOf(LocalDateTime.now().minusDays(random.nextInt(30)));

                reviewStatement.setObject(1, reviewId);
                reviewStatement.setObject(2, creatorId);
                reviewStatement.setObject(3, bidderId);
                reviewStatement.setInt(4, rating);
                reviewStatement.setString(5, comment);
                reviewStatement.setTimestamp(6, createdAt);
                reviewStatement.addBatch();

                if (++batchCount % batchSize == 0) {
                    reviewStatement.executeBatch();
                }
            }
            reviewStatement.executeBatch();

        }
    }
}
