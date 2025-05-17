package com.polinadragun.db.runner;

import com.polinadragun.db.abstractions.Seeder;
import com.polinadragun.db.seeders.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

public class SeedersRunner {

    private static <T extends Seeder> List<T> selectLatestVersions(List<T> seederClasses)
            throws InstantiationException, IllegalAccessException {

        List<T> result = new ArrayList<>();
        for (T seederClass : seederClasses) {
            if (seederClass.getVersion() == 1) {
                T current = seederClass;
                Class<T> clazz = (Class<T>) current.getClass();
                for (T posmaxseederClass : seederClasses) {
                    if (clazz.isAssignableFrom(posmaxseederClass.getClass())) {
                        if (posmaxseederClass.getVersion() > current.getVersion()) {
                            current = posmaxseederClass;
                        }
                    }
                }
                result.add(current);
            }
        }
        return result;
    }
    public static void run() throws Exception , IOException {
        String env = System.getenv("APP_ENV");
        if (!"dev".equalsIgnoreCase(env)) {
            System.out.println("Not in dev ");
            return;
        }

        String url = System.getenv("URL");

        Properties props = new Properties();
        props.setProperty("user", System.getenv("POSTGRES_USER"));
        props.setProperty("password", System.getenv("POSTGRES_PASSWORD"));
        try (Connection connection = DriverManager.getConnection(url, props)) {
            System.out.println("connected to db....");

//            List<BasicDataSeeder>  dataSeeders = new ArrayList<>();
//            dataSeeders.add(new ProfileTypesSeeder());
//            dataSeeders.add(new RegionsSeeder());
//            dataSeeders.add(new RolesSeeder());
//            dataSeeders.add(new SpecializationsSeeder());
//            dataSeeders.add(new StatusCodesSeeder());
//
//            List<BasicFakerSeeder> fakerSeeders = new ArrayList<>();
//            fakerSeeders.add(new UsersSeeder());
//            fakerSeeders.add(new UserRelationsSeeder());
//            fakerSeeders.add(new ProfilesAndDetailsSeeder());
//            fakerSeeders.add(new VerificationDataSeeder());
//            fakerSeeders.add(new PublicationsWithMediaAndBidsSeeder());
//            fakerSeeders.add(new PortfolioAndReviewsSeeder());
//
//            for (BasicDataSeeder dataSeeder : dataSeeders) {
//                dataSeeder.seed(connection);
//            }
//
//            for (BasicFakerSeeder fakerSeeder : fakerSeeders) {
//                fakerSeeder.seed(connection);
//            }

            List<Seeder> seeders = new ArrayList<>();
            seeders.add(new ProfileTypesSeeder());
           seeders.add(new RegionsSeeder());
           seeders.add(new RolesSeeder());
          seeders.add(new SpecializationsSeeder());
          seeders.add(new StatusCodesSeeder());
            seeders.add(new UsersSeeder());
            seeders.add(new UserRelationsSeeder());
            seeders.add(new ProfilesAndDetailsSeeder());
            seeders.add(new VerificationDataSeeder());
            seeders.add(new PublicationsWithMediaAndBidsSeeder());
            seeders.add(new PortfolioAndReviewsSeeder());
            seeders.add(new RolesSeederExtra());

            List<Seeder> latestseeders = selectLatestVersions(seeders);
            for (Seeder seederClass : latestseeders) {
                seederClass.seed(connection);
            }
        }

    }
}
