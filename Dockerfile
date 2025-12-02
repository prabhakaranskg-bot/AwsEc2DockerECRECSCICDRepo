# Stage 1: Build the Spring Boot app
FROM eclipse-temurin:17-jdk AS build

# Install tools
RUN apt-get update && apt-get install -y git curl unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy all files from project into container
COPY . .

# Make mvnw executable and build
RUN chmod +x mvnw
RUN ./mvnw clean package -DskipTests

# Stage 2: Run the app
FROM eclipse-temurin:21-jdk

WORKDIR /app

# Copy the jar from the build stage
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
