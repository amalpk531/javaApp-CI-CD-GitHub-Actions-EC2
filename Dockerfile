# ── Stage 1: Build ──────────────────────────────────────────────
# Use full Maven + JDK image to compile and package the app
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first — lets Docker cache the dependency download layer
# so re-builds don't re-download all dependencies unless pom.xml changes
COPY pom.xml .
RUN mvn dependency:go-offline -q

# Now copy source and build the fat JAR
COPY src ./src
RUN mvn package -DskipTests -q

# ── Stage 2: Run ─────────────────────────────────────────────────
# Use minimal JRE-only image — no Maven, no JDK, much smaller image
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy only the compiled JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the port Spring Boot runs on
EXPOSE 8080

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
