# Use Maven for building and include Docker CLI
FROM maven:3.8.4-openjdk-17 AS build
# Install Docker CLI
USER root
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli
USER jenkins

WORKDIR /app
COPY . .
RUN mvn clean install -DskipTests

# Use Zulu OpenJDK 17 for runtime
FROM azul/zulu-openjdk:17
WORKDIR /app
COPY --from=build /app/target/spring-petclinic*.jar /app/spring-petclinic.jar
CMD ["java", "-jar", "-Dserver.port=8085", "spring-petclinic.jar"]
