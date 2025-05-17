This project implements a database management system using PostgreSQL with Flyway for schema migrations and a Java-based seeder for test data generation. The migrations use idempotent SQL scripts to ensure reliability, while the seeder supports versioning through Java annotations and handles over 30 database relations with realistic test data.

The system includes automated role-based access control with read-only analyst users and provides containerized deployment through Docker. The solution supports environment-specific configurations for both schema migrations and data seeding workflows.
