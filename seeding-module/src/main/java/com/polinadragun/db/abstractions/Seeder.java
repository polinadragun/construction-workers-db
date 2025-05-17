package com.polinadragun.db.abstractions;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

public interface Seeder {
    void seed(Connection connection) throws SQLException, IOException;

    int getVersion();
}
