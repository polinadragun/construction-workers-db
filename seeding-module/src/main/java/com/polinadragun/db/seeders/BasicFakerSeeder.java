package com.polinadragun.db.seeders;

import com.github.javafaker.Faker;
import com.polinadragun.db.abstractions.Seeder;
import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.utils.Env;

import java.util.Random;

public abstract class BasicFakerSeeder implements Seeder {
    protected final Faker faker = new Faker();
    protected final Random random = new Random();
    protected final int seedCount = Env.SEED_COUNT;
    protected final int batchSize = Env.BATCH_SIZE;

    public int getVersion() {
        Version annotation = this.getClass().getAnnotation(Version.class);
        return annotation != null ? annotation.value() : 0;
    }
}
