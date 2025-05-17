package com.polinadragun.db.utils;

import java.util.Optional;

public class Env {
    public static final int SEED_COUNT =
            Optional.ofNullable(System.getenv("SEED_COUNT")).map(Integer::parseInt).orElse(0);
    public static int BATCH_SIZE = SEED_COUNT > 10000 ? SEED_COUNT / 100 : SEED_COUNT;
}
