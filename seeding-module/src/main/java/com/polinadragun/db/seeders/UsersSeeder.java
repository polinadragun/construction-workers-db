package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.UUID;

@Version(1)
public class UsersSeeder extends BasicFakerSeeder {


    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("users.sql");

        PreparedStatement statement = connection.prepareStatement(sql);

        for (int i = 0; i < seedCount; i++) {
            statement.setObject(1, UUID.randomUUID());
            statement.setString(2, faker.internet().emailAddress());
            statement.setString(3, faker.crypto().sha256());
            statement.setString(4, faker.name().fullName());
            statement.setString(5, faker.phoneNumber().subscriberNumber(11));
            statement.addBatch();

            if (i % batchSize == 0) {
                statement.executeBatch();
            }
        }
        statement.executeBatch();
        System.out.println("Seeded users: " + seedCount);
    }
}
