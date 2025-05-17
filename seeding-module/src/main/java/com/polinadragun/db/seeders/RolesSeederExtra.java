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
        //some changes or ovverrides for suiting new migrations
    }
}
