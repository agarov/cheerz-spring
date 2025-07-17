# --- Stage 1: Build the application ---
FROM gradle:8.5-jdk17 AS builder

# Create app directory
WORKDIR /app

# Copy Gradle wrapper files (for caching)
COPY gradle gradle
COPY gradlew .
COPY build.gradle settings.gradle ./

# Pre-download dependencies
RUN ./gradlew dependencies --no-daemon

# Copy source files
COPY src ./src

# Build the application
RUN ./gradlew bootJar --no-daemon

# --- Stage 2: Run the application ---
FROM eclipse-temurin:17-jre-alpine

# Create app directory
WORKDIR /app

# Copy built jar from previous stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Expose application port (e.g., 8080)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
