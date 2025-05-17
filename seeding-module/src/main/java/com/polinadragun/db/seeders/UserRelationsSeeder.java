package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.*;
import java.util.UUID;

@Version(1)
public class UserRelationsSeeder extends BasicFakerSeeder {

    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        seedUserRoles(connection);
        seedUserSpecializations(connection);
        seedUserRegions(connection);
    }

    private void seedUserRoles(Connection connection) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("user_roles.sql");

        try (PreparedStatement statement = connection.prepareStatement(sql);
             Statement userstatement = connection.createStatement();
             ResultSet users = userstatement.executeQuery("SELECT id FROM users")) {

            String[] roleCodes = {"admin", "customer", "gencontractor", "contractor", "subcontractor", "moderator"};

            while (users.next()) {
                UUID userId = (UUID) users.getObject("id");

                String randomRole = roleCodes[random.nextInt(roleCodes.length)];

                statement.setObject(1, userId);
                statement.setString(2, randomRole);
                statement.addBatch();
            }
            statement.executeBatch();
            System.out.println("Seeded user_roles");
        }
    }

    public void seedUserSpecializations(Connection connection) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("user_spec.sql");

        try (PreparedStatement statement = connection.prepareStatement(sql);
             Statement userstatement = connection.createStatement();
             ResultSet users = userstatement.executeQuery("SELECT id FROM users")) {

            String[] specCodes = {"spec01", "spec02", "spec03", "spec04", "spec05", "spec06"};

            while (users.next()) {
                UUID userId = (UUID) users.getObject("id");

                int specializationsCount = 1 + random.nextInt(3);

                for (int i = 0; i < specializationsCount; i++) {
                    String randomSpec = specCodes[random.nextInt(specCodes.length)];
                    statement.setObject(1, userId);
                    statement.setString(2, randomSpec);
                    statement.addBatch();
                }
            }
            statement.executeBatch();
            System.out.println("Seeded user_specializations");
        }
    }

    public void seedUserRegions(Connection conn) throws SQLException {
        String sql = "INSERT INTO user_regions (user_id, region_code) VALUES (?, ?) ON CONFLICT DO NOTHING";

        try (PreparedStatement statement = conn.prepareStatement(sql)) {
            Statement userstatement = conn.createStatement();
            ResultSet users = userstatement.executeQuery("SELECT id FROM users");

            short[] regionCodes = {77, 78, 50, 66, 23, 24, 16, 55, 54, 38};

            while (users.next()) {
                UUID userId = (UUID) users.getObject("id");

                int regionCount = 1 + random.nextInt(3);

                for (int i = 0; i < regionCount; i++) {
                    short randomRegion = regionCodes[random.nextInt(regionCodes.length)];
                    statement.setObject(1, userId);
                    statement.setShort(2, randomRegion);
                    statement.addBatch();
                }
            }
            statement.executeBatch();
            System.out.println("Seeded user_regions");
        }
    }
}
