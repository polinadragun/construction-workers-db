package com.polinadragun.db.seeders;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.polinadragun.db.abstractions.Seeder;
import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.dto.BasicData;

import java.io.IOException;
import java.io.InputStream;

public abstract class BasicDataSeeder  implements Seeder {
    protected static final BasicData basicData;

    static {
        ObjectMapper objectMapper = new ObjectMapper();
        InputStream is = BasicDataSeeder.class.getResourceAsStream("/baseData/data.json");
        try {
            basicData = objectMapper.readValue(is, BasicData.class);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public int getVersion() {
        Version annotation = this.getClass().getAnnotation(Version.class);
        return annotation != null ? annotation.value() : 0;
    }
}
