package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.dto.BasicData;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@Version(1)
public class RolesSeeder extends BasicDataSeeder {

    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("roles.sql");

        PreparedStatement statement = connection.prepareStatement(sql);

        for (BasicData.Role role : basicData.getRoles()) {
            statement.setString(1, role.getRole_code());
            statement.setBoolean(2, role.isRequires_legal_profiles());
            statement.addBatch();
        }
        statement.executeBatch();
        System.out.println("Seeded roles");
    }

}
