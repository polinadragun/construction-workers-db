package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

@Version(1)
public class PublicationsWithMediaAndBidsSeeder extends BasicFakerSeeder {

    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        List<UUID> createdTenderIds = new ArrayList<>();
        List<UUID> createdOrderIds = new ArrayList<>();

        String sql = SqlLoader.loadSql("can_publicate_users.sql");

        String publicationSql = SqlLoader.loadSql("publications.sql");

        String tenderSql = SqlLoader.loadSql("tenders.sql");

        String orderSql = SqlLoader.loadSql("orders.sql");

        String mediaSql = SqlLoader.loadSql("publication_mediafiles.sql");

        PreparedStatement statement = connection.prepareStatement(sql);

        PreparedStatement pubStatement = connection.prepareStatement(publicationSql);
        PreparedStatement tenderStatement = connection.prepareStatement(tenderSql);
        PreparedStatement orderStatement = connection.prepareStatement(orderSql);
        PreparedStatement mediaStatement = connection.prepareStatement(mediaSql);

        statement.setFetchSize(batchSize);
        ResultSet rs = statement.executeQuery();
        int batchCount = 0;

        while (rs.next()) {
            UUID creatorId = (UUID) rs.getObject("id");
            String role = rs.getString("role_code");

            UUID publicationId = UUID.randomUUID();
            String publicationStatus = random.nextBoolean() ? "published" : "draft";
            String title = faker.lorem().characters(100, 250);
            String description = faker.lorem().characters(100, 250);
            Timestamp deadline = Timestamp.valueOf(LocalDateTime.now().plusDays(30 + random.nextInt(28)));
            Timestamp createdAt = Timestamp.valueOf(LocalDateTime.now().minusDays(random.nextInt(30)));

            String publicationType;
            boolean isTender = false;
            boolean canCreateTender = role.equals("customer") || role.equals("gencontractor");
            boolean canCreateOrder = role.equals("gencontractor") || role.equals("contractor");

            if (canCreateTender && canCreateOrder) {
                isTender = random.nextBoolean();
            } else if (canCreateTender) {
                isTender = true;
            } else if (canCreateOrder) {
                isTender = false;
            }

            publicationType = isTender ? "tender" : "order";

            pubStatement.setObject(1, publicationId);
            pubStatement.setObject(2, creatorId);
            pubStatement.setString(3, publicationStatus);
            pubStatement.setString(4, title);
            pubStatement.setString(5, description);
            pubStatement.setTimestamp(6, deadline);
            pubStatement.setTimestamp(7, createdAt);
            pubStatement.setString(8, publicationType);

            pubStatement.addBatch();

            int mediafilesCount = 1 + random.nextInt(5);
            String[] filetypes = {"mp3", "ogg", "wav", "jpg", "jpeg", "png"};

            for (int j = 0; j < mediafilesCount; j++) {
                mediaStatement.setObject(1, UUID.randomUUID());
                mediaStatement.setObject(2, publicationId);
                mediaStatement.setString(3, faker.internet().url());
                mediaStatement.setString(4, randomChoice(filetypes));
                mediaStatement.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now().minusDays(random.nextInt(30))));

                mediaStatement.addBatch();
            }

            if (isTender) {
                UUID tenderId = UUID.randomUUID();
                Timestamp submissionDeadline = Timestamp.valueOf(LocalDateTime.now().plusDays(10 + random.nextInt(20)));

                tenderStatement.setObject(1, tenderId);
                tenderStatement.setObject(2, publicationId);
                tenderStatement.setTimestamp(3, submissionDeadline);
                tenderStatement.setString(4, faker.lorem().sentence());
                tenderStatement.setString(5, faker.lorem().sentence());
                tenderStatement.setString(6, faker.lorem().paragraph());
                tenderStatement.setBigDecimal(7, BigDecimal.valueOf(10000 + random.nextInt(100000)));
                tenderStatement.setInt(8, random.nextInt(10));
                tenderStatement.setInt(9, 12 + random.nextInt(24));
                tenderStatement.setString(10, random.nextBoolean() ? "open" : "closed");

                createdTenderIds.add(tenderId);

                tenderStatement.addBatch();

            } else {
                UUID orderId = UUID.randomUUID();
                Timestamp deliveryDate = Timestamp.valueOf(LocalDateTime.now().plusDays(20 + random.nextInt(32)));

                orderStatement.setObject(1, orderId);
                orderStatement.setObject(2, publicationId);
                orderStatement.setTimestamp(3, deliveryDate);
                orderStatement.setString(4, faker.lorem().characters(100, 255));
                createdOrderIds.add(orderId);

                orderStatement.addBatch();
            }

            if (++batchCount % batchSize == 0) {
                pubStatement.executeBatch();
                tenderStatement.executeBatch();
                orderStatement.executeBatch();
                mediaStatement.executeBatch();
            }
        }
        pubStatement.executeBatch();
        tenderStatement.executeBatch();
        orderStatement.executeBatch();
        mediaStatement.executeBatch();

        seedBids(connection);
        seedPublicationSpecializations(connection);
        seedPublicationRegions(connection);

        System.out.println("Seeded publications + related tenders/orders.");

    }

    private void seedBids(Connection connection) throws SQLException, IOException {
        String tenderQuery = "SELECT id FROM tenders";
        String orderQuery = "SELECT id FROM orders";

        String tenderBidSql = SqlLoader.loadSql("tender_bids.sql");

        String orderBidSql = SqlLoader.loadSql("order_bids.sql");

        String tenderDocsSql = SqlLoader.loadSql("tender_bid_docs.sql");

        String bidEvalSql = SqlLoader.loadSql("tender_bid_eval.sql");

        PreparedStatement tenderBidStatement = connection.prepareStatement(tenderBidSql);
        PreparedStatement orderBidStatement = connection.prepareStatement(orderBidSql);
        PreparedStatement tenderDocsStatement = connection.prepareStatement(tenderDocsSql);
        PreparedStatement bidEvalStatement = connection.prepareStatement(bidEvalSql);

        Map<String, List<UUID>> eligibleBidders = loadUsersByRolesForBidding(connection);
        String[] filetypes = {"pdf", "ppt", "pptx", "xls", "xlsx", "doc", "docx"};

        PreparedStatement tenderStatement = connection.prepareStatement(tenderQuery);
        tenderStatement.setFetchSize(batchSize);
        ResultSet tenderRs = tenderStatement.executeQuery();
        int tenderWithBidsCount = 0;

        while (tenderRs.next()) {
            UUID tenderId = (UUID) tenderRs.getObject("id");

            List<UUID> createdTenderBidIds = new ArrayList<>();
            int bidsCount = 1 + random.nextInt(5);

            for (int i = 0; i < bidsCount; i++) {
                UUID bidId = UUID.randomUUID();
                Timestamp createdAt = Timestamp.valueOf(LocalDateTime.now().minusDays(random.nextInt(30)));

                tenderBidStatement.setObject(1, bidId);
                tenderBidStatement.setObject(2, tenderId);
                tenderBidStatement.setObject(3, getRandomItem(eligibleBidders.get("tender")));
                tenderBidStatement.setString(4, random.nextBoolean() ? "submitted" : "draft");
                tenderBidStatement.setString(5, faker.lorem().paragraph());
                tenderBidStatement.setTimestamp(6, createdAt);
                tenderBidStatement.setInt(7, 12 + random.nextInt(24));
                tenderBidStatement.setInt(8, 30 + random.nextInt(90));

                tenderBidStatement.addBatch();

                createdTenderBidIds.add(bidId);
            }
            if (++tenderWithBidsCount % batchSize == 0) {
                tenderBidStatement.executeBatch();
            }

            for (UUID bidId : createdTenderBidIds) {
                int docsCount = 1 + random.nextInt(3);
                for (int j = 0; j < docsCount; j++) {
                    tenderDocsStatement.setObject(1, UUID.randomUUID());
                    tenderDocsStatement.setObject(2, bidId);
                    tenderDocsStatement.setString(3, faker.internet().url());
                    tenderDocsStatement.setString(4, randomChoice(filetypes));
                    tenderDocsStatement.setString(5, faker.lorem().characters(100, 250));
                    tenderDocsStatement.addBatch();
                }

                int evalCount = 1 + random.nextInt(3);
                for (int j = 0; j < evalCount; j++) {
                    bidEvalStatement.setObject(1, UUID.randomUUID());
                    bidEvalStatement.setObject(2, bidId);
                    bidEvalStatement.setString(3, faker.name().fullName());
                    bidEvalStatement.setBigDecimal(4, BigDecimal.valueOf(random.nextDouble(5.0)).setScale(2, RoundingMode.HALF_UP));
                    bidEvalStatement.setString(5, faker.lorem().paragraph());
                    bidEvalStatement.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now().minusDays(random.nextInt(30))));
                    bidEvalStatement.addBatch();
                }
            }
            if (tenderWithBidsCount % batchSize == 0) {
                tenderDocsStatement.executeBatch();
                bidEvalStatement.executeBatch();
            }
        }

        tenderBidStatement.executeBatch();
        tenderDocsStatement.executeBatch();
        bidEvalStatement.executeBatch();



        PreparedStatement orderStatement = connection.prepareStatement(orderQuery);
        orderStatement.setFetchSize(1000);
        ResultSet orderRs = orderStatement.executeQuery();

        int orderWithBidsCount = 0;

        while (orderRs.next()) {
            UUID orderId = (UUID) orderRs.getObject("id");

            if (eligibleBidders.get("order").isEmpty()) continue;

            int bidsCount = 1 + random.nextInt(5);
            for (int i = 0; i < bidsCount; i++) {
                UUID bidId = UUID.randomUUID();
                Timestamp createdAt = Timestamp.valueOf(LocalDateTime.now().minusDays(random.nextInt(30)));

                orderBidStatement.setObject(1, bidId);
                orderBidStatement.setObject(2, orderId);
                orderBidStatement.setObject(3, getRandomItem(eligibleBidders.get("order")));
                orderBidStatement.setString(4, random.nextBoolean() ? "submitted" : "draft");
                orderBidStatement.setTimestamp(5, createdAt);
                orderBidStatement.setString(6, faker.lorem().sentence());

                orderBidStatement.addBatch();
            }
            if (++orderWithBidsCount % batchSize == 0) {
                orderBidStatement.executeBatch();
            }
        }
        orderBidStatement.executeBatch();

        System.out.println("Seeded bids for tenders and orders.");
    }


    private Map<String, List<UUID>> loadUsersByRolesForBidding(Connection conn) throws SQLException {
        List<UUID> usersByRoleForTender = new ArrayList<>(loadUserIdsByRole(conn, "contractor"));
        usersByRoleForTender.addAll(loadUserIdsByRole(conn, "gencontractor"));

        List<UUID> usersByRoleForOrder = new ArrayList<>(loadUserIdsByRole(conn, "contractor"));
        usersByRoleForOrder.addAll(loadUserIdsByRole(conn, "subcontractor"));

        return new HashMap<>() {{
            put("tender", usersByRoleForTender);
            put("order", usersByRoleForOrder);
        }};
    }
    private List<UUID> loadUserIdsByRole(Connection conn, String role) throws SQLException {
        String query = "SELECT user_id FROM user_roles WHERE role_code = ?";
        try (PreparedStatement Statement = conn.prepareStatement(query)) {
            Statement.setString(1, role);
            try (ResultSet rs = Statement.executeQuery()) {
                List<UUID> userIds = new ArrayList<>();
                while (rs.next()) {
                    userIds.add((UUID) rs.getObject("user_id"));
                }
                return userIds;
            }
        }
    }

    public void seedPublicationSpecializations(Connection connection) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("publication_spec.sql");

        try (PreparedStatement statement = connection.prepareStatement(sql);
             Statement pubStatement = connection.createStatement();
             ResultSet publications = pubStatement.executeQuery("SELECT id FROM publications")) {

            String[] specCodes = {"spec01", "spec02", "spec03", "spec04", "spec05", "spec06"};

            while (publications.next()) {
                UUID publicationId = (UUID) publications.getObject("id");

                int specializationCount = 1 + random.nextInt(3);

                for (int i = 0; i < specializationCount; i++) {
                    String randomSpec = randomChoice(specCodes);
                    statement.setObject(1, publicationId);
                    statement.setString(2, randomSpec);
                    statement.addBatch();
                }
            }
            statement.executeBatch();
            System.out.println("Seeded publication_specializations");
        }
    }

    public void seedPublicationRegions(Connection connection) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("publication_regions.sql");

        try (PreparedStatement Statement = connection.prepareStatement(sql);
             Statement pubStatement = connection.createStatement();
             ResultSet publications = pubStatement.executeQuery("SELECT id FROM publications")) {

            short[] regionCodes = {77, 78, 50, 66, 23, 24, 16, 55, 54, 38};

            while (publications.next()) {
                UUID publicationId = (UUID) publications.getObject("id");

                int regionCount = 1 + random.nextInt(5);

                for (int i = 0; i < regionCount; i++) {
                    short randomRegion = regionCodes[random.nextInt(regionCodes.length)];
                    Statement.setObject(1, publicationId);
                    Statement.setShort(2, randomRegion);
                    Statement.addBatch();
                }
            }
            Statement.executeBatch();
            System.out.println("Seeded publication_regions");
        }
    }

    private UUID getRandomItem(List<UUID> list) {
        return list.get(random.nextInt(list.size()));
    }
    
    private String randomChoice(String[] array) {
        return array[random.nextInt(array.length)];
    }
}
