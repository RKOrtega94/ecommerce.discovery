FROM openjdk:24-jdk-slim

ARG SERVER_PORT=8080
ARG ACTIVE_PROFILE=default
ARG APPLICATION_NAME=application-name
ARG BUILD_VERSION=1.0.0

RUN apt-get update && \
  apt-get install -y --no-install-recommends curl && \
  rm -rf /var/lib/apt/lists/* && \
  adduser --system --no-create-home --group appuser

WORKDIR /app

COPY build/libs/${APPLICATION_NAME}-${BUILD_VERSION}.jar app.jar
RUN mkdir -p /app/logs && \
  mkdir -p /app/keys && \
  chown -R appuser:appuser /app

USER appuser

EXPOSE ${SERVER_PORT}
ENTRYPOINT ["java", "-jar", "app.jar", "-Dserver.port=${SERVER_PORT}", "-Dspring.profiles.active=${ACTIVE_PROFILE}"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:"$SERVER_PORT"/health/"$APPLICATION_NAME"/status || exit 1