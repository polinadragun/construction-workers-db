package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.dto.BasicData;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@Version(1)
public class RegionsSeeder extends BasicDataSeeder {

    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        String sql = SqlLoader.loadSql("regions.sql");
        PreparedStatement statement = connection.prepareStatement(sql);

        for (BasicData.Region region : basicData.getRegions()) {
            statement.setShort(1, Short.parseShort(region.getRegion_code()));
            statement.setString(2, region.getName());
            statement.addBatch();
        }
        statement.executeBatch();
        System.out.println("Seeded regions");
    }
}
