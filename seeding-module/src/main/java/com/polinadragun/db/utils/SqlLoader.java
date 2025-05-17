package com.polinadragun.db.utils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

public class SqlLoader {
    public static String loadSql(String filename) throws IOException {
        try (InputStream is = SqlLoader.class.getResourceAsStream("/sql/" + filename)) {
            if (is == null) {
                throw new IOException("SQL file not found: " + filename);
            }
            return new String(is.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
}