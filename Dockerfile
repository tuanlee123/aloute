# Stage 1: Build mã nguồn thành file WAR bằng Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

ENV MAVEN_OPTS="-Dfile.encoding=UTF-8"

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests -Dfile.encoding=UTF-8

# Stage 2: Runtime
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

COPY --from=build /app/target/*.war app.war

EXPOSE 8080

ENTRYPOINT ["java", "-Dfile.encoding=UTF-8", "-Dspring.profiles.active=prod", "-jar", "app.war"]