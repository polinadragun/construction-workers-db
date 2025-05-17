package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.dto.BasicData;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@Version(1)
public class SpecializationsSeeder extends BasicDataSeeder {

    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("specializations.sql");

        PreparedStatement statement = connection.prepareStatement(sql);
        for (BasicData.Specialization spec : basicData.getSpecializations()) {
            statement.setString(1, spec.getSpec_code());
            statement.setString(2, spec.getName());
            statement.addBatch();
        }
        statement.executeBatch();
        System.out.println("Seeded specializations");
    }
}
