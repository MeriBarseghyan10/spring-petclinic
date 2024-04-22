# Start with the Jenkins inbound agent image
FROM jenkins/inbound-agent:latest as jenkins-agent

# Switch to root to install packages
USER root

# Install necessary packages for adding Docker repository and Docker CLI
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

# Return to the jenkins user
USER jenkins

# Set work directory
WORKDIR /home/jenkins

# Optionally, if you need to build a Java project with Maven as part of the Jenkins job:
# Use Maven for building the Java project
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean install -DskipTests

# In this scenario, assuming that you need to use the built Java artifact in the Jenkins agent:
# Use Zulu OpenJDK 17 to run the Java application
FROM azul/zulu-openjdk:17
WORKDIR /app
COPY --from=build /app/target/spring-petclinic*.jar /app/spring-petclinic.jar

# Copy the built Java application to the Jenkins agent image
# Note: This step assumes you are using this image to run the Java app, which may not be typical for a Jenkins agent.
COPY --from=azul/zulu-openjdk:17 /app/spring-petclinic.jar /home/jenkins/spring-petclinic.jar

# Command to run the application, this should typically be handled by Jenkins steps instead
# CMD ["java", "-jar", "-Dserver.port=8085", "spring-petclinic.jar"]
