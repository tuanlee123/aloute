# Stage 1: Build mã nguồn thành file WAR bằng Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Sao chép pom.xml và tải dependencies trước để tối ưu cache
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Sao chép toàn bộ mã nguồn và đóng gói
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Chạy ứng dụng bằng JDK 17
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# Copy file war đã build từ stage 1
COPY --from=build /app/target/*.war app.war

# Khai báo cổng web
EXPOSE 8080

# Chạy ứng dụng với profile production
ENTRYPOINT ["java", "-Dspring.profiles.active=prod", "-jar", "app.war"]