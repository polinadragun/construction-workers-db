FROM openjdk:21-slim


WORKDIR /app

COPY build/libs/load-emulator-1.0-SNAPSHOT.jar app.jar

ENTRYPOINT bash -c "java -jar app.jar"
