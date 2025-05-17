package com.polinadragun.db.seeders;

import com.polinadragun.db.annotations.Version;
import com.polinadragun.db.utils.SqlLoader;

import java.io.IOException;
import java.sql.*;
import java.util.UUID;

@Version(1)
public class VerificationDataSeeder extends BasicFakerSeeder {
    @Override
    public void seed(Connection connection) throws SQLException, IOException {
        String[] verificationStatuses = {"passed", "pending", "failed"};
        String[] documentTypes = {"passport", "registration_certificate", "license", "other"};
        String[] signatureProviders = {"Госуслуги","КриптоПро", "Контур", "Тензор", "Другой провайдер"};


        Statement statement = connection.createStatement();
        statement.setFetchSize(batchSize);
        ResultSet rs = statement.executeQuery("SELECT id FROM profiles");

        String insertDocumentSQL = SqlLoader.loadSql("verification_docs.sql");
        String insertESignatureSQL = SqlLoader.loadSql("e_signature.sql");

        PreparedStatement documentStatement = connection.prepareStatement(insertDocumentSQL);
        PreparedStatement signatureStatement = connection.prepareStatement(insertESignatureSQL);

        int count = 0;
        while (rs.next()) {
            int documentsCount = 1 + random.nextInt(2);
            for (int i = 0; i < documentsCount; i++) {
                documentStatement.setObject(1, UUID.randomUUID());
                documentStatement.setObject(2, rs.getObject("id"));
                documentStatement.setString(3, randomChoice(verificationStatuses));
                documentStatement.setString(4, randomChoice(documentTypes));
                documentStatement.setString(5, faker.internet().url());
                documentStatement.setString(6, faker.lorem().characters(100, 250));
                documentStatement.addBatch();
            }

            signatureStatement.setObject(1, UUID.randomUUID());
            signatureStatement.setObject(2, rs.getObject("id"));
            signatureStatement.setString(3, randomChoice(verificationStatuses));
            signatureStatement.setString(4, randomChoice(signatureProviders));
            signatureStatement.addBatch();

            if (++count % batchSize == 0) {
                documentStatement.executeBatch();
                signatureStatement.executeBatch();
            }
        }

        documentStatement.executeBatch();
        signatureStatement.executeBatch();

        System.out.println("Seeded verification documents and e-signature verifications.");
    }

    private String randomChoice(String[] array) {
        return array[random.nextInt(array.length)];
    }
}
