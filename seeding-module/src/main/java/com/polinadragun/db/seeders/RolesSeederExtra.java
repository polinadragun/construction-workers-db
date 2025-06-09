package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.dto.BasicData;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@Version(2)
public class RolesSeederExtra extends RolesSeeder {

    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        super.seed(connection);
        String sql = SqlLoader.loadSql("roles.sql");

        PreparedStatement statement = connection.prepareStatement(sql);

        statement.setString(1, "NikitaMatsnev");
        statement.setBoolean(2, false);
        statement.addBatch();

        statement.executeBatch();
    }
}
