# Build
FROM eclipse-temurin:21-jdk AS build

WORKDIR /app

COPY . .
RUN --mount=type=cache,target=/root/.gradle ./gradlew clean test bootWar --no-daemon

# Exécution
FROM eclipse-temurin:21-jre-alpine

RUN addgroup -S app && adduser -S app -G app

WORKDIR /app

COPY --from=build /app/build/libs/*.war app.war

USER app

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.war"]
