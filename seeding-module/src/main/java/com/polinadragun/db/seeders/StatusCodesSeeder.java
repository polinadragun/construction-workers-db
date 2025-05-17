package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@Version(1)
public class StatusCodesSeeder extends BasicDataSeeder {
    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        seedVerificationStatusCodes(connection);
        seedPublicationStatusCodes(connection);
        seedBidStatusCodes(connection);
    }

    public static void seedVerificationStatusCodes(Connection connection) throws SQLException, IOException {
        String[][] statuses = {
                {"passed", "Проверка пройдена"}, {"failed", "Проверка не пройдена"}, {"pending", "Ожидает проверки"}
        };
        String sql = SqlLoader.loadSql("verificationstatcode.sql");

        PreparedStatement statement = connection.prepareStatement(sql);
        for (String[] status : statuses) {
            statement.setString(1, status[0]);
            statement.setString(2, status[1]);
            statement.addBatch();
        }
        statement.executeBatch();
        System.out.println("Seeded verification status codes");
    }

    private static void seedPublicationStatusCodes(Connection connection) throws SQLException, IOException {
        String[][] statuses = {
                {"draft", "Черновик"}, {"published", "Опубликовано"}, {"archived", "В архиве"}
        };
        String sql = SqlLoader.loadSql("publicationstatcode.sql");

        PreparedStatement statement = connection.prepareStatement(sql);
        for (String[] status : statuses) {
            statement.setString(1, status[0]);
            statement.setString(2, status[1]);
            statement.addBatch();
        }
        statement.executeBatch();
        System.out.println("Seeded publication status codes");
    }

    private static void seedBidStatusCodes(Connection connection) throws SQLException, IOException {
        String[][] statuses = {
                {"draft", "Черновик"}, {"submitted", "Подан"}, {"selected", "Выбран для исполнения"}
        };
        String sql = SqlLoader.loadSql("bidstatcode.sql");

        PreparedStatement statement = connection.prepareStatement(sql);
        for (String[] status : statuses) {
            statement.setString(1, status[0]);
            statement.setString(2, status[1]);
            statement.addBatch();
        }
        statement.executeBatch();
        System.out.println("Seeded bid status codes");
    }
}
