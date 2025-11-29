# Use official OpenJDK 21 image
FROM eclipse-temurin:21-jdk

# Set working directory
WORKDIR /app

# Copy SSL certs/resources if needed
# COPY src/main/resources /app/resources

# Copy Spring Boot fat JAR
COPY target/AwsEc2DockerECRECSCICD-0.0.1-SNAPSHOT.jar app.jar

# Expose port 8080
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
