package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@Version(1)
public class ProfileTypesSeeder extends BasicDataSeeder{
    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        String[][] types = {
                {"gov", "Госорган"}, {"company", "Юридическое лицо"},
                {"ip", "Физическое лицо"}, {"person", "Индивидуальный предприниматель"}
        };
        String sql = SqlLoader.loadSql("profile_types.sql");

        PreparedStatement statement = connection.prepareStatement(sql);
        for (String[] type : types) {
            statement.setString(1, type[0]);
            statement.setString(2, type[1]);
            statement.addBatch();
        }
        statement.executeBatch();
        System.out.println("Seeded legal profile types");
    }
}
