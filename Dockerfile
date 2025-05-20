# Use a JDK image for building
FROM openjdk:17 AS build

# Set working directory inside container
WORKDIR /app

# Copy Gradle wrapper files and build files first to leverage Docker cache
COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle settings.gradle ./

# Give execute permission to gradlew
RUN chmod +x gradlew

# Pre-download dependencies
RUN ./gradlew dependencies --no-daemon || true

# Copy the rest of the project
COPY . .

# Build the application (creates JAR)
RUN ./gradlew build --no-daemon

# Final image for running
FROM openjdk:17-slim

WORKDIR /app

# Copy only the JAR file from build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose app port if necessary
EXPOSE 8080

# Run the app
CMD ["java", "-jar", "app.jar"]
