package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.*;
import java.util.UUID;

@Version(1)
public class ProfilesAndDetailsSeeder extends BasicFakerSeeder {
    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        String[] legalTypes = {"gov", "company", "ip", "person"};

        String insertProfileSQL = SqlLoader.loadSql("profiles.sql");
        String insertGovDetails = SqlLoader.loadSql("gov_profile_details.sql");
        String insertCompanyDetails = SqlLoader.loadSql("company_profile_details.sql");
        String insertIpDetails = SqlLoader.loadSql("ip_profile_details.sql");
        String insertPersonDetails = SqlLoader.loadSql("person_profile_details.sql");


        PreparedStatement profileStatement = connection.prepareStatement(insertProfileSQL);
        PreparedStatement govStatement = connection.prepareStatement(insertGovDetails);
        PreparedStatement companyStatement = connection.prepareStatement(insertCompanyDetails);
        PreparedStatement ipStatement = connection.prepareStatement(insertIpDetails);
        PreparedStatement personStatement = connection.prepareStatement(insertPersonDetails);

        Statement Statement = connection.createStatement();
        ResultSet rs = Statement.executeQuery("SELECT id FROM users");
        
        int count = 0;
        while (rs.next()) {
            count++;
            UUID profileId = UUID.randomUUID();
            String legalType = legalTypes[(int) (Math.random() * legalTypes.length)];
            String verificationStatus = "passed";

            profileStatement.setObject(1, profileId);
            profileStatement.setObject(2, rs.getObject("id"));
            profileStatement.setString(3, legalType);
            profileStatement.setString(4, verificationStatus);
            profileStatement.setString(5, faker.lorem().characters(100, 250));
            profileStatement.addBatch();

            switch (legalType) {
                case "gov":
                    govStatement.setObject(1, UUID.randomUUID());
                    govStatement.setObject(2, profileId);
                    govStatement.setString(3, faker.number().digits(10));
                    govStatement.setString(4, faker.number().digits(9));
                    govStatement.setString(5, faker.number().digits(13));
                    govStatement.setString(6, faker.name().fullName());
                    govStatement.addBatch();
                    break;
                case "company":
                    companyStatement.setObject(1, UUID.randomUUID());
                    companyStatement.setObject(2, profileId);
                    companyStatement.setString(3, faker.number().digits(10));
                    companyStatement.setString(4, faker.number().digits(13));
                    companyStatement.setString(5, faker.number().digits(9));
                    companyStatement.setString(6, faker.number().digits(8));
                    companyStatement.setString(7, faker.company().name());
                    companyStatement.addBatch();
                    break;
                case "ip":
                    ipStatement.setObject(1, UUID.randomUUID());
                    ipStatement.setObject(2, profileId);
                    ipStatement.setString(3, faker.number().digits(12));
                    ipStatement.setString(4, faker.number().digits(15));
                    ipStatement.setString(5, faker.name().fullName());
                    ipStatement.addBatch();
                    break;
                case "person":
                    personStatement.setObject(1, UUID.randomUUID());
                    personStatement.setObject(2, profileId);
                    personStatement.setString(3, faker.number().digits(12));
                    personStatement.addBatch();
                    break;
            }

            if (count % batchSize == 0) {
                profileStatement.executeBatch();
                govStatement.executeBatch();
                companyStatement.executeBatch();
                ipStatement.executeBatch();
                personStatement.executeBatch();
            }
        }

        profileStatement.executeBatch();
        govStatement.executeBatch();
        companyStatement.executeBatch();
        ipStatement.executeBatch();
        personStatement.executeBatch();

        System.out.println("Seeded profiles and their details:");
    }

}

