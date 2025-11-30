# Base image for Spring Boot
FROM eclipse-temurin:21-jdk-jammy

# Set working directory
WORKDIR /app

# Copy Maven wrapper and project files
COPY pom.xml mvnw ./
COPY mvnw.cmd ./
COPY src ./src

# Make mvnw executable
RUN chmod +x mvnw

# Build Spring Boot app using Maven wrapper
RUN ./mvnw clean package -DskipTests

# Copy built jar to a clean image
FROM eclipse-temurin:21-jdk-jammy
WORKDIR /app

COPY --from=0 /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run Spring Boot app
ENTRYPOINT ["java","-jar","app.jar"]
